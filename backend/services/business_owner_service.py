# app/services/business_owner_service.py
import bcrypt
from bson import ObjectId
from models.business_owner import BusinessOwner
from schemas.business_owner import BusinessOwnerResponse, BusinessOwnerCreate
from utils.pyobjectid import PyObjectId
from db.init_db import db


def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

class BusinessOwnerService:
    def __init__(self):
        self.db = db # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_new_business_owner(self, business_owner_create: BusinessOwnerCreate):
        # Create a new business owner in the database
        # Default not validated as a business owner
        business_owner = BusinessOwner(name=business_owner_create.name, email=business_owner_create.email, password=hash_password(business_owner_create.password), isVerified=business_owner_create.isVerified)
        result = await self.db.business_owners.insert_one(business_owner.to_dict())
        return {**business_owner.to_dict(), "id": str(result.inserted_id)}
    
    async def delete_business_owner(self, _id: str) -> bool:
        # Delete a owner from database by email
        PyObjectId.validate(_id)
        
        result = await self.db.business_owners.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1

    async def get_business_owner_by_email(self, email: str):
        # Fetch a business owner from the database by business owner
        business_owner_data = await self.db.business_owners.find_one({"email": email})
        business_owner = BusinessOwnerResponse(**business_owner_data)
        if business_owner:
            return business_owner
        return None

    async def get_business_owners(self):
        # Fetch all business owner from the database
        business_owners = await self.db.business_owners.find().to_list(100)
        business_owners = [BusinessOwnerResponse(**business_owner) for business_owner in business_owners]
        return business_owners
    
    async def verify_business_owner(self, owner_id: str):
        # Mark a business owner as verified
        result = await self.db.business_owners.update_one(
            {"_id": ObjectId(owner_id)}, 
            {"$set": {"isVerified": True}}
        )
        return result.modified_count > 0  # Returns True if an update was made