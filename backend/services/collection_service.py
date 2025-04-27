from services.base_service import BaseService
from typing import List
from schemas.collection import CollectionCreate, CollectionResponse, CollectionAdd, CollectionEdit
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
    
    async def edit_collection(self, collection: CollectionEdit):
        """
        Edit a collection's name
        """
        # Find the existing collection by ID
        existing_collection = await self.db.collections.find_one({"_id": ObjectId(collection.collection_id)})
        
        if not existing_collection:
            print("no collection")
            return None
        
        # Get the names of the other collections under this user
        # This is to ensure we do not have duplicate collection names for the same user
        existing_collections = await self.db.collections.find({
            "user_id": existing_collection["user_id"],
            "_id": {"$ne": ObjectId(collection.collection_id)} # Exclude the current collection being edited
        }).to_list(length=None)

        # Check for duplicate names
        for existing in existing_collections:
            if existing["name"] == collection.name:
                print(f"A collection with the name '{collection.name}' already exists for this user.")
                return None
        
        # Update the collection's name
        result = await self.db.collections.update_one(
            {"_id": ObjectId(collection.collection_id)},
            {"$set": {"name": collection.name}}
        )

        print(result.modified_count)
        
        if result.modified_count == 1:
            updated_collection = await self.db.collections.find_one({"_id": ObjectId(collection.collection_id)})
            if updated_collection:
                updated_collection["_id"] = str(updated_collection["_id"])
                print("success!")
                return CollectionResponse(**updated_collection)
        else:
            # If no documents were modified, return None
            print("No modifications made to the collection.")
            return None

    async def remove_business_from_collection(self, collection):
        """
        Remove a business from a collection
        """
        collection_id = ObjectId(collection.collection_id)
        business_id = ObjectId(collection.business_id)

        # Find the existing collection by ID
        existing_collection = await self.db.collections.find_one({"_id": collection_id})
        if not existing_collection:
            print("no collection")
            return None
        
        # Remove the business from the collection
        result = await self.db.collections.update_one(
            {"_id": collection_id},
            {"$pull": {"businesses": {"business_id": str(business_id)}}} # Use $pull to remove the business entry from the array
        )

        print("result is ", result)

        if result.modified_count == 1:
            # Successfully removed the business, return the updated collection
            updated_collection = await self.db.collections.find_one({"_id": collection_id})
            if updated_collection:
                updated_collection["_id"] = str(updated_collection["_id"])
                return CollectionResponse(**updated_collection)
        else:
            # If no documents were modified, return None
            print("No modifications made to the collection.")
            return None