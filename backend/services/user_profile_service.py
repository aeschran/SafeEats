# app/services/user_service.py
import bcrypt
from models.profile import Profile
from schemas.profile import ProfileResponse, ProfileCreate, ProfileUpdate, OtherProfileResponse, ProfileSearchResponse
from services.base_service import BaseService
import logging
from bson import ObjectId
from typing import List
from fastapi import HTTPException


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
class UserProfileService(BaseService):
    def __init__(self):
        super().__init__() # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_new_profile(self, _id: str, profile_create: ProfileCreate):

        user = await self.db.users.find_one({"_id": ObjectId(_id)})
        name = user["name"]
        profile = Profile(name=name, bio=profile_create.bio, friend_count=profile_create.friend_count, review_count=profile_create.review_count, image=profile_create.image, preferences=profile_create.preferences)
        result = await self.db.users.update_one({"_id": ObjectId(_id)}, {"$set": profile.to_dict()}, upsert=False)
        image_dict = profile.get_image()
        image_dict["user_id"] = _id
        print(image_dict)
        if result.matched_count == 0 and not result.upserted_id:
            return None
        result = await self.db.user_profile_images.insert_one(image_dict)


        
        return {**profile.to_dict(), "id": str(_id)}
    
    async def update_user_profile(self, user_id: str, update: ProfileUpdate):
        update_data = {k: v for k, v in update.dict().items() if v is not None}

        result = await self.db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {k: v for k, v in update_data.items() if k != "image"}}
        )
        if "image" in update_data:
            await self.db.user_profile_images.update_one(
                {"user_id": user_id},
                {"$set": {"image": update_data["image"]}},
                upsert=True
            )


        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Profile not updated or not found")
        return {"message": "Profile updated successfully"}


    async def get_user_profile(self, _id: str):
        user_data = await self.db.users.find_one({"_id": ObjectId(_id)}) 
        if not user_data:
            return None
        user_image = await self.db.user_profile_images.find_one({"user_id": str(_id)})
        user = ProfileResponse(**user_data)
        if user:
            if user_image:
                user = user.copy(update={"image": user_image["image"]})
            else:
                user = user.copy(update={"image": None})
            return user
        return None
    
    async def get_other_user_profile(self, _id: str, friend_id: str):
        user_data = await self.db.users.find_one({"_id": ObjectId(friend_id)}) 
        if not user_data:
            return None
        user_image = await self.db.user_profile_images.find_one({"user_id": str(friend_id)})
        user = OtherProfileResponse(**user_data)
        friend_data = await self.db.friends.find_one({"user_id": ObjectId(_id), "friend_id": ObjectId(friend_id)})
        if not friend_data:
            friend_data = await self.db.friends.find_one({"user_id": ObjectId(friend_id), "friend_id": ObjectId(_id)})
        notifications_data = await self.db.notifications.find_one({"user_id": ObjectId(_id), "friend_id": ObjectId(friend_id)})
        if not notifications_data:
            notifications_data = await self.db.notifications.find_one({"sender_id": ObjectId(friend_id), "recipient_id": ObjectId(_id)})
        if user:
            if friend_data:
                if user_image:
                    print("1")
                    user = user.copy(update={"image": user_image["image"], "is_following": True, "is_requested": False})
                else:  
                    print("2")
                    user = user.copy(update={"image": None, "is_following": True, "is_requested": False})
            else:
                if notifications_data:
                    if user_image:
                        user = user.copy(update={"image": user_image["image"], "is_following": False, "is_requested": True})
                    else:
                        user = user.copy(update={"is_following": False, "image": None, "is_requested": True})
                else:
                    if user_image:
                        user = user.copy(update={"image": user_image["image"], "is_following": False, "is_requested": False})
                    else:
                        user = user.copy(update={"is_following": False, "image": None, "is_requested": False})

                    # user = user.copy(update={"image": user_image["image"], "is_following": False})
                # else:
                    # print("4")
                    # user = user.copy(update={"is_following": False, "image": None})
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

    async def get_profile_search(self, _id: str, query: str) -> List[ProfileSearchResponse]:
        try:
            # user_id = ObjectId(_id)
            search_results = await self.db.users.find(
            {
                    "$and": [
                        {"$or": [
                            {"name": {"$regex": query, "$options": "i"}},  # Case-insensitive name search
                            {"username": {"$regex": query, "$options": "i"}}  # Case-insensitive username search
                        ]},
                        {"_id": {"$ne": ObjectId(_id)}}  # Exclude the current user by ID
                    ]
                },
                {"_id": 1, "name": 1, "username": 1}
            ).to_list(length=10)  # Limit to 10 results
            profiles = [{"id": str(user["_id"]), "name": user["name"], "username": user["username"]} for user in search_results]
            return profiles

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    # Convert MongoDB documents into Pydantic response model
        return [
        ProfileSearchResponse(id=str(user["_id"]), name=user["name"], username=user["username"])
        for user in search_results
        ]
    
    async def get_user_preferences(self, _id: str):
        user_data = await self.db.users.find_one({"_id": ObjectId(_id)})
        if user_data:
            user = ProfileResponse(**user_data)
            result = {
                "dietary_restrictions": [pref.dict() for pref in user.preferences]
            }
            print(result)
            return result
        return None
    
    async def update_user_preferences(self, _id: str, new_preferences: dict):
        user_data = await self.db.users.find_one({"_id": ObjectId(_id)})
        if user_data:
            update_result = await self.db.users.update_one(
                {"_id": ObjectId(_id)},
                {"$set": {"preferences": new_preferences.get("preferences", [])}})
            
            if update_result.modified_count > 0:
                return {"message": "Preferences updated successfully."}
            else:
                return {"message": "No changes were made to the preferences."}
        
        return None

    


