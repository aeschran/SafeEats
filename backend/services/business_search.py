import random
from bson import ObjectId
import requests
from core.config import settings
from services.base_service import BaseService
from schemas.business import BusinessCreate, BusinessResponse, BusinessSearch, BusinessAndLocationResponse
from services.business_service import BusinessService

class BusinessSearchService(BaseService):
    def __init__(self, limit: int = 50):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        self.business_service = BusinessService()
        self.limit = limit
        self.headers = {
            "accept": "application/json",
            "Authorization": settings.FOURSQUARE_SECRET
        }
        self.url = "https://api.foursquare.com/v3/places/search"
        self.cuisine_ranges = []
        self.mapping = {
            "Asian": 13100,
            "Italian": 13236,
            "Mexican": 13308,
            "Indian": 13198
        }

    async def search_operator(self, business_search: BusinessSearch):
        if business_search.cuisines == []:
            self.cuisine_ranges = []
        else:
            cuisine_list = [self.mapping[cuisine] for cuisine in business_search.cuisines]
            self.cuisine_ranges = await self.get_cuisine_ranges(cuisine_list)
        if business_search.radius != 5000:
            return await self.get_businesses_within_radius(business_search)
        if business_search.query != "restaurant" and business_search.query != "":
            return await self.search_by_lat_long(business_search)
        else:
            return await self.query_db_by_lat_long(business_search)

    async def search_by_near_address(self, near: str = "West Lafayette, IN", query: str = "restaurant"):
        params = {
            "near": near,
            "query": query,
            "limit": self.limit,
            "fields": "name,website,tel,description,categories,menu,geocodes,location,social_media,price,hours"
        }

        response = requests.get(self.url, params=params, headers=self.headers)

        return response.json()
    
    async def search_by_lat_long(self, business_search: BusinessSearch):
        url = "https://api.foursquare.com/v3/places/search"
        params = {
            "ll": f"{business_search.lat},{business_search.lon}",
            "query": business_search.query,
            "limit": self.limit,
            "fields": "name,website,tel,description,categories,menu,geocodes,location,social_media,price,hours"
        }

        response = requests.get(self.url, params=params, headers=self.headers)

        results_dict = []
        for result in response.json()['results']:
            valid = False
            for cuisine in result['categories']:
                if cuisine['id'] - 13000 >= 0 and cuisine['id'] - 13000 < 1000:
                    valid = True
                    break
            if not valid:
                continue
            results_dict.append({
                "name": result['name'],
                "owner_id": None,
                "website": result['website'] if 'website' in result else None,
                "tel": result['tel'] if 'tel' in result else None,
                "description": result['description'] if 'description' in result else None,
                "cuisines": [result['categories'][i]['id'] for i in range(len(result['categories']))] if 'categories' in result else [],
                "menu": result['menu'] if 'menu' in result else None,
                "address": result['location']['formatted_address'] if 'location' in result and 'formatted_address' in result['location'] else None,
                "location": {
                    "type": "Point",
                    "coordinates": [result['geocodes']['main']['longitude'] if 'geocodes' in result and 'main' in result['geocodes'] and 'longitude' in result['geocodes']['main'] else 0.0,
                    result['geocodes']['main']['latitude'] if 'geocodes' in result and 'main' in result['geocodes'] and 'latitude' in result['geocodes']['main'] else 0.0
                    ]
                },
                "dietary_restrictions": result['dietary_restrictions'] if 'dietary_restrictions' in result else [],
                "social_media": {
                    "facebook_id": result["social_media"].get("facebook_id") if "social_media" in result else None,
                    "instagram": result["social_media"].get("instagram") if "social_media" in result else None,
                    "twitter": result["social_media"].get("twitter") if "social_media" in result else None,
                },
                "price": result['price'] if 'price' in result else None,
                "hours": {
                    "display": result['hours'].get("display") if "hours" in result else None,
                    "is_local_holiday": result['hours'].get("is_local_holiday") if "hours" in result else None,
                    "open_now": result['hours'].get("open_now") if "hours" in result else None,
                    "regular": result['hours'].get("regular") if "hours" in result else None,
                },
            })
            
        businesses_to_create = [BusinessCreate(**result) for result in results_dict]
        db_businesses = []
        for business in businesses_to_create:
            await self.business_service.create_business(business)
        for business in businesses_to_create:
            if self.cuisine_ranges == []:
                    db_businesses.append(await self.business_service.get_business_by_name_and_location(business))
            else:
                for cuisine in business.cuisines:
                    found = False
                    for cuisine_type in self.cuisine_ranges:
                        for cuisine_range in cuisine_type['ranges']:
                            if cuisine <= cuisine_range['max'] and cuisine >= cuisine_range['min']:
                                found = True
                                break
                        if found:
                            db_businesses.append(await self.business_service.get_business_by_name_and_location(business))
                            break
        final_businesses = []

        if business_search.dietary_restrictions:
            for business in db_businesses:
                match_count = sum(
                    1
                    for restriction in business_search.dietary_restrictions
                    for business_restriction in business['dietary_restrictions']
                    if restriction.preference == business_restriction['preference']
                )
                final_businesses.append({
                    "business": business,
                    "match_count": match_count
                })
            # Sort businesses by match_count in descending order
            final_businesses.sort(key=lambda x: x["match_count"], reverse=True)

            # Extract sorted businesses
            final_businesses = [item["business"] for item in final_businesses]
        else:
            final_businesses = db_businesses
        return [BusinessResponse(**business) for business in final_businesses]
    
    async def query_db_by_lat_long(self, business_search: BusinessSearch):
        db_results = await self.db.businesses.find({
            "location.coordinates": {
                "$near": {
                    "$geometry": {
                        "type": "Point",
                        "coordinates": [business_search.lon, business_search.lat]
                    }
                }
            }
        }).to_list(10)
        db_businesses = []
        if self.cuisine_ranges != []:
            for business in db_results:
                for cuisine in business['cuisines']:
                    found = False
                    for cuisine_type in self.cuisine_ranges:
                        for cuisine_range in cuisine_type['ranges']:
                            if cuisine <= cuisine_range['max'] and cuisine >= cuisine_range['min']:
                                found = True
                                break
                        if found:
                            db_businesses.append(business)
                            break
        else:
            db_businesses = db_results
        final_businesses = []

        if business_search.dietary_restrictions:
            for business in db_businesses:
                match_count = sum(
                    1
                    for restriction in business_search.dietary_restrictions
                    for business_restriction in business['dietary_restrictions']
                    if restriction.preference == business_restriction['preference']
                )
                final_businesses.append({
                    "business": business,
                    "match_count": match_count
                })
            # Sort businesses by match_count in descending order
            final_businesses.sort(key=lambda x: x["match_count"], reverse=True)

            # Extract sorted businesses
            final_businesses = [item["business"] for item in final_businesses]
        else:
            final_businesses = db_businesses
        return [BusinessResponse(**business) for business in final_businesses]
        
    

    async def find_list_of_businesses_in_db(self, businesses: list):
        return [await self.business_service.get_business_by_name_and_location(business) for business in businesses]

    async def get_all_cuisine_ranges(self):
        results = await self.db.cuisines.find().to_list()
        return results
    
    async def get_cuisine_ranges(self, cuisine_numbers: list):
        cuisines = []
        
        # Iterate through the cuisine_numbers and check against the ranges
        for number in cuisine_numbers:
            # Query the database to find all cuisines where the number falls within any range
            async for cuisine in self.db.cuisines.find({
                "ranges": {
                    "$elemMatch": {
                        "$and": [
                            {"min": {"$lte": number}},  # The number must be greater than or equal to the "min"
                            {"max": {"$gte": number}}   # The number must be less than or equal to the "max"
                        ]
                    }
                }
            }):
                cuisines.append(cuisine)

        return cuisines
    
    async def get_business_by_id(self, business_id: str):
        """
        Get a business by its ID from the database
        """
        try:
            print(f"Retrieving business by id: {business_id}")
            business = await self.db.businesses.find_one({"_id": ObjectId(business_id)}) # Ensure to convert business_id to ObjectId
            if business is None:
                return None
            return BusinessResponse(**business)
        except Exception as e:
            print(f"Error retrieving business by id: {e}")
            return None
    
    async def get_businesses_within_radius(self, business_search: BusinessSearch):
        # Fetch businesses from the database within the specified radius
        businesses = await self.db.businesses.find({
            "location.coordinates": {
                "$geoWithin": {
                    "$centerSphere": [
                        [business_search.lon, business_search.lat],
                        business_search.radius / 3963.2  # Convert radius to radians
                    ]
                }
            }
        }).to_list()

        response = []
        for business in businesses:
            response.append({
                "_id": business["_id"],
                "name": business["name"],
                "website": business["website"],
                "description": business["description"],
                "cuisines": business["cuisines"],
                "menu": business["menu"],
                "address": business["address"],
                "location": {
                    "lat": business["location"]["coordinates"][1],
                    "lon": business["location"]["coordinates"][0]
                },
                "dietary_restrictions": business["dietary_restrictions"],
                "avg_rating": business["avg_rating"] if "avg_rating" in business else 0.0,
                "tel": business["tel"] if "tel" in business else None,
                "social_media": business["social_media"] if "social_media" in business else None,
                "price": business['price'] if 'price' in business else None,
                "hours": business['hours'] if 'hours' in business else None,
            })

        db_businesses = []
        if self.cuisine_ranges != []:
            for business in response:
                for cuisine in business['cuisines']:
                    found = False
                    for cuisine_type in self.cuisine_ranges:
                        for cuisine_range in cuisine_type['ranges']:
                            if cuisine <= cuisine_range['max'] and cuisine >= cuisine_range['min']:
                                found = True
                                break
                        if found:
                            db_businesses.append(business)
                            break
        else:
            db_businesses = response
        final_businesses = [BusinessAndLocationResponse(**business) for business in db_businesses]
        return final_businesses
    
    async def get_random_business(self, business_search: BusinessSearch):
        businesses = await self.search_operator(business_search)

        if not businesses:
            return None

        return random.choice(businesses)
