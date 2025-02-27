import requests
from core.config import settings
from services.base_service import BaseService
from schemas.business import BusinessCreate, BusinessResponse, BusinessSearch
from services.business_service import BusinessService

class BusinessSearchService(BaseService):
    def __init__(self, limit: int = 10):
        super().__init__()
        self.business_service = BusinessService()
        self.limit = limit
        self.headers = {
            "accept": "application/json",
            "Authorization": settings.FOURSQUARE_SECRET
        }
        self.url = "https://api.foursquare.com/v3/places/search"

    async def search_by_near_address(self, near: str = "West Lafayette, IN", query: str = "restaurant"):
        params = {
            "near": near,
            "query": query,
            "limit": self.limit
        }

        response = requests.get(self.url, params=params, headers=self.headers)

        return response.json()
    
    async def search_by_lat_long(self, business_search: BusinessSearch):
        url = "https://api.foursquare.com/v3/places/search"
        params = {
            "ll": f"{business_search.lat},{business_search.lon}",
            "query": business_search.query,
            "limit": self.limit,
            "fields": "name,website,description,categories,menu,geocodes,location"
        }

        response = requests.get(self.url, params=params, headers=self.headers)
        print(response.json())
        results_dict = []
        for result in response.json()['results']:
            results_dict.append({
                "name": result['name'],
                "owner_id": None,
                "website": result['website'] if 'website' in result else None,
                "description": result['description'] if 'description' in result else None,
                "cuisines": [result['categories'][i]['name'] for i in range(len(result['categories']))] if 'categories' in result else [],
                "menu": result['menu'] if 'menu' in result else None,
                "address": result['location']['formatted_address'] if 'location' in result and 'formatted_address' in result['location'] else None,
                "location": {
                    "lat": result['geocodes']['main']['latitude'] if 'geocodes' in result and 'main' in result['geocodes'] and 'latitude' in result['geocodes']['main'] else 0.0,
                    "lon": result['geocodes']['main']['longitude'] if 'geocodes' in result and 'main' in result['geocodes'] and 'longitude' in result['geocodes']['main'] else 0.0
                },
                "dietary_restrictions": result['dietary_restrictions'] if 'dietary_restrictions' in result else []
            })
        businesses_to_create = [BusinessCreate(**result) for result in results_dict]
        for business in businesses_to_create:
            await self.business_service.create_business(business)
        results = [BusinessResponse(**result) for result in results_dict]
        return results

