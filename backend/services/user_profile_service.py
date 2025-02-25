# app/services/user_service.py
import bcrypt
from models.profile import Profile
from schemas.profile import ProfileResponse, ProfileCreate
from services.base_service import BaseService
import logging
from bson import ObjectId


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
class UserProfileService(BaseService):
    def __init__(self):
        super().__init__() # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_new_profile(self, _id: str, profile_create: ProfileCreate):

        user = await self.db.users.find_one({"_id": ObjectId(_id)})
        name = user.get("name")
        profile = Profile(name=name, bio=profile_create.bio, friend_count=profile_create.friend_count, review_count=profile_create.review_count, image=profile_create.image, preferences=profile_create.preferences)
        result = await self.db.users.update_one({"_id": ObjectId(_id)}, {"$set": profile.to_dict()}, upsert=False)
        image_dict = profile.get_image()
        image_dict["user_id"] = _id
        print(image_dict)
        if result.matched_count == 0 and not result.upserted_id:
            return None
        result = await self.db.user_profile_images.insert_one(image_dict)


        
        return {**profile.to_dict(), "id": str(_id)}


    async def get_user_profile(self, _id: str):
        user_data = await self.db.users.find_one({"_id": ObjectId(_id)}) 
        if not user_data:
            return None
        user_image = await self.db.user_profile_images.find_one({"user_id": str(_id)})
        user = ProfileResponse(**user_data)
        if user:
            user = user.copy(update={"image": user_image["image"]})
            return user
        return None

    # async def get_users(self):
    #     # Fetch all users from the database
    #     users = await self.db.users.find().to_list(100)
    #     users = [UserResponse(**user) for user in users]
    #     return users

    async def savePicture(self, _id: str, imageUrl: str):
        
        self.db.users.find_one_and_update({"_id": ObjectId(_id)}, {"$set": { "imageUrl": imageUrl }})
        return True