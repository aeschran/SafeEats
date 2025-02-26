from models.friend import Friend
from schemas.friend import FriendCreate, FriendResponse
from services.base_service import BaseService
import logging
from bson import ObjectId
from fastapi import HTTPException
import time

class FriendService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        
    async def create_new_friend(self, friend_create: FriendCreate):
        try :
            friend = Friend(user_id=ObjectId(friend_create.user_id), friend_id=ObjectId(friend_create.friend_id))
            result = await self.db.friends.insert_one(friend.to_dict())
            update_user_count = await self.db.users.update_one({"_id": ObjectId(friend_create.user_id)}, {"$inc": {"friend_count" : 1}})
            update_friend_count = await self.db.users.update_one({"_id": ObjectId(friend_create.friend_id)}, {"$inc": {"friend_count" : 1}})
            if result.inserted_id:
                return FriendResponse(**friend.to_dict())
            return None
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    async def get_friends(self, user_id: str):
        # user_id = ObjectId(user_id)
        # user_id = ObjectId(user_id)

        friends = await self.db.friends.aggregate([
            {
                "$match": { "user_id": ObjectId(user_id) }
            },
            {
                "$project": {
                    "_id": 0, 
                    "friend_id": 1, 
                    "friend_since": 1
                }
            },
            {
                "$group": {
                    "_id": None,
                    "friends": { "$push": { "friend_id": "$friend_id", "friend_since": "$friend_since" } }
                }
            },
            {
                "$project": { "_id": 0, "friends": 1 }
            }
            ]).to_list(length=None)
        friends_list = []
        if not friends:
            return friends_list
        else:
            
            for friend in friends[0]["friends"]:
                friend_id = friend["friend_id"]
                user_data = await self.db.users.find_one(
                    {"_id": ObjectId(friend_id)},
                    {"name": 1, "username": 1}
                )
                if user_data:
                    friends_list.append({
                        "friend_id": str(friend_id),  # Convert to string for JSON compatibility
                        "friend_since": friend["friend_since"],
                        "name": user_data["name"],
                        "username": user_data["username"],
                    })
        return friends_list
    
    async def delete_friend(self, _id: str) -> bool:
        result = await self.db.friends.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1
    
    async def delete_all_friends(self, user_id: str) -> bool:
        user_id = ObjectId(user_id)
        result = await self.db.friends.delete_many({"user_id": user_id})
        return result.deleted_count > 0