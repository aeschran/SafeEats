from models.business import Business
from schemas.business import BusinessCreate, BusinessResponse, BusinessAddPreferences, EditBusiness
from services.base_service import BaseService
from typing import List
from bson import ObjectId
from models.location import Location

class BusinessService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_business(self, business: BusinessCreate):
        updated_location = Location(coordinates=[business.location.coordinates[0], business.location.coordinates[1]])
        new_business = Business(
            name=business.name,
            owner_id=business.owner_id,
            website=business.website,
            tel=business.tel,
            description=business.description,
            cuisines=business.cuisines,
            menu=business.menu,
            address=business.address,
            location=updated_location,
            dietary_restrictions=business.dietary_restrictions,
            avg_rating=business.avg_rating,
            social_media=business.social_media
        )
        existing_doc = await self.db.businesses.find_one({
            "name": business.name,
            "address": business.address,
        })

        if not existing_doc:
            business_id = await self.db.businesses.insert_one(new_business.to_dict())
            added_business = new_business.to_dict()
            added_business["_id"] = business_id.inserted_id
            return BusinessResponse(**added_business)
        else:
            existing_avg_rating = existing_doc.get("avg_rating", 0.0)  # Preserve existing rating
            business.avg_rating = existing_avg_rating  # Assign it before updating
            return self.update_business(business_id=existing_doc["_id"], business=business)

    def get_businesses(self):
        businesses = self.db.businesses.find()
        return [BusinessResponse(**business) for business in businesses]

    def get_business_by_id(self, business_id: ObjectId):
        business = self.db.businesses.find_one({"_id": business_id})
        if business:
            return BusinessResponse(**business)
        return None
    
    async def get_business_by_name_and_location(self, business: BusinessCreate):
        #updated_location = Location(coordinates=[business.location.coordinates[0], business.location.coordinates[1]])
        business = await self.db.businesses.find_one({
            "name": business.name,
            "address": business.address
        })
        if business:
            return business
        return

    def update_business(self, business_id: ObjectId, business: BusinessCreate):
        updated_location = Location(coordinates=[business.location.coordinates[0], business.location.coordinates[1]])
        updated_business = Business(
            name=business.name,
            owner_id=business.owner_id,
            website=business.website,
            tel=business.tel,
            description=business.description,
            cuisines=business.cuisines,
            menu=business.menu,
            address=business.address,
            location=updated_location,
            dietary_restrictions=business.dietary_restrictions,
            avg_rating=business.avg_rating,
            social_media=business.social_media
        )
        update_data = {k: v for k, v in updated_business.to_dict().items() if v is not None}

        # Prevent overwriting dietary_restrictions with an empty list -> May need to change this
        if business.dietary_restrictions == []:
            update_data.pop("dietary_restrictions", None)

        result = self.db.businesses.update_one({"_id": business_id}, {"$set": update_data})
        # result = self.db.businesses.update_one({"_id": business_id}, {"$set": updated_business.to_dict()})
        update_data["_id"] = business_id
        if result is None:
            return None
        response = BusinessResponse(**update_data)
        return response
    
    def delete_business(self, business_id: ObjectId):
        result = self.db.businesses.delete_one({"_id": business_id})
        if result.deleted_count == 0:
            return None
        return True
    
    async def get_average_rating(self, business_id: str) -> float:
        business_object_id = ObjectId(business_id)
        business = await self.db.businesses.find_one({"_id": business_object_id}, {"avg_rating": 1})
        if business and "avg_rating" in business:
            return business["avg_rating"]
        return 0.0
    
    async def update_average_rating(self, business_id: str):
        business_object_id = ObjectId(business_id)
        
        # ratings = await self.db.user_reviews.find({"business_id": business_object_id}).to_list(length=None)
        # print(f"Ratings: {[r['rating'] for r in ratings]}")

        pipeline = [
            {"$match": {"business_id": business_object_id}}, 
            {"$group": {"_id": None, "avg_rating": {"$avg": "$rating"}}} 
        ]

        result = await self.db.user_reviews.aggregate(pipeline).to_list(length=1)
        

        if result:
            avg_rating = result[0]["avg_rating"]
        else:
            avg_rating = 0.0

        avg_rating = round(avg_rating, 1)

        await self.db.businesses.update_one(
            {"_id": business_object_id},
            {"$set": {"avg_rating": float(avg_rating)}}

        )

        return avg_rating

    
    async def get_review_count(self, business_id: str) -> int:
        business_object_id = ObjectId(business_id)

        count = await self.db.user_reviews.count_documents({"business_id": business_object_id})
        return count
    
    async def add_preferences_to_business(self, business_id:str, preferences: BusinessAddPreferences):
        business_object_id = ObjectId(business_id)
        dietPref = preferences.dietPref
        allergy = preferences.allergy

        print(preferences)

        updatedList = []
        for diet in dietPref:
            updatedList.append({"preference": diet, "preference_type": "Dietary Restriction"})
        
        for allerg in allergy:
            updatedList.append({"preference": allerg, "preference_type": "Allergy"})

        print(f"Adding dietary restrictions/allergies to business {business_id}: {updatedList}")

        result = await self.db.businesses.update_one(
            {"_id": business_object_id},
            {"$set": {"dietary_restrictions": updatedList}}
        )
        return result.modified_count > 0
    
    async def edit_business(self, business_id: str, update_data: EditBusiness):
        business_object_id = ObjectId(business_id)

        # Extract top-level fields (excluding social media)
        update_dict = {}

        if update_data.website is not None:
            update_dict["website"] = update_data.website
        if update_data.tel is not None:
            update_dict["tel"] = update_data.tel

        # Fetch current social media data
        current_business = await self.db.businesses.find_one({"_id": business_object_id})
        if not current_business:
            raise ValueError("Business not found")

        current_social = current_business.get("social_media", {})
        updated_social = current_social.copy()

        if update_data.instagram and update_data.instagram.strip():
            updated_social["instagram"] = update_data.instagram.strip()
        if update_data.twitter and update_data.twitter.strip():
            updated_social["twitter"] = update_data.twitter.strip()
        if update_data.facebook_id and update_data.facebook_id.strip():
            updated_social["facebook_id"] = update_data.facebook_id.strip()

        if updated_social != current_social:
            update_dict["social_media"] = updated_social

        if not update_dict:
            raise ValueError("No fields provided for update")

        result = await self.db.businesses.update_one(
            {"_id": business_object_id},
            {"$set": update_dict}
        )

        if result.matched_count == 0:
            raise ValueError("Business not found")

        return result.modified_count > 0

    

    
    