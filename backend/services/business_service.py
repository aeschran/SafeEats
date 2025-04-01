from models.business import Business
from schemas.business import BusinessCreate, BusinessResponse
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
            description=business.description,
            cuisines=business.cuisines,
            menu=business.menu,
            address=business.address,
            location=updated_location,
            dietary_restrictions=business.dietary_restrictions
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
            description=business.description,
            cuisines=business.cuisines,
            menu=business.menu,
            address=business.address,
            location=updated_location,
            dietary_restrictions=business.dietary_restrictions
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