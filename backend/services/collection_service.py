from services.base_service import BaseService
from typing import List
from schemas.collection import CollectionCreate, CollectionResponse, CollectionAdd
from models.collection import Collection
from models.business import BusinessCollectionEntry
from bson import ObjectId

class CollectionService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_collection(self, collection: CollectionCreate):
        new_collection = Collection(
            name=collection.name,
            user_id=collection.user_id,
            businesses=collection.businesses
        )
        existing_doc = await self.db.collections.find_one({
            "name": collection.name,
            "user_id": collection.user_id
        })

        if not existing_doc:
            collection_id = await self.db.collections.insert_one(new_collection.to_dict())
            added_collection = new_collection.to_dict()
            added_collection["_id"] = collection_id.inserted_id
            return CollectionResponse(**added_collection)
        else:
            return self.update_collection(collection_id=existing_doc["_id"], collection=collection)
        
    async def get_collections(self, user_id: str):
        cursor = self.db.collections.find({"user_id": user_id})
        collections = []
        async for document in cursor:
            document["_id"] = str(document["_id"]) if "_id" in document else None # Ensure _id is a string for CollectionResponse
            businesses = document.get("businesses", [])
            for business in businesses:
                # Ensure each business entry has the required fields
                print(business)
                business["business_id"] = str(business.get("business_id", None)) if "business_id" in business else None # Ensure business_id is a string
                if business["business_description"] == None:
                    business["business_description"] = ""
            collections.append(CollectionResponse(**document))
        print(collections)
        return collections
    
    async def add_business_to_collection(self, collection: CollectionAdd):
        """
        Add a business to an existing collection
        """
        print(collection)
        user_id = collection.user_id
        collection_name = collection.collection_name
        business_id = collection.business_id

        existing_collection = await self.db.collections.find_one({"user_id": user_id, "name": collection_name})
        if not existing_collection:
            return None

        business = await self.db.businesses.find_one({"_id": ObjectId(business_id)})
        if not business:
            print(f"Business with id {business_id} does not exist.")
            return None
        
        if business["description"] == None:
            business["description"] = "" # Fallback to empty string if description is None, to avoid breaking the BusinessCollectionEntry
        
        newBusiness = BusinessCollectionEntry(
            business_id=str(business.get("_id", str(business_id))), # Fallback to str if _id not found
            business_name=business.get("name", ""), # Fallback to empty string if name not found
            business_description=business.get("description", ""), # Fallback to empty string if description not found
            business_address=business.get("address", "") # Fallback to empty string if address not found
        ).to_dict()
        
        # Update the collection by adding the business_id to the businesses list
        
        result = await self.db.collections.update_one(
            {"_id": existing_collection["_id"]},
            {"$addToSet": {"businesses": newBusiness}} # Use $addToSet to avoid duplicates in the array
        )
        
        if result.modified_count == 1:
            updated_collection = await self.db.collections.find_one({"_id": existing_collection["_id"]})
            print(updated_collection)
            return CollectionResponse(**updated_collection)
        
        return None
