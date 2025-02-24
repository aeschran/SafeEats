from models.friend import Friend
from schemas.friend import FriendCreate, FriendResponse
from services.base_service import BaseService
import logging
from bson import ObjectId

class FriendService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        
    async def create_new_friend(self, friend_create: FriendCreate):
        friend = Friend(user_id=ObjectId(friend_create.user_id), friend_id=ObjectId(friend_create.friend_id))
        result = await self.db.friends.insert_one(friend.to_dict())
        if result.inserted_id:
            return FriendResponse(**friend.to_dict())
        return None
    
    async def get_friends(self, user_id: str):
        user_id = ObjectId(user_id)
        pipeline = [
        {"$match": {"user_id": user_id}},  # Filter by user ID
        {
            "$lookup": {
                "from": "users",  # Users collection
                "localField": "friend_id",  # Field in friends
                "foreignField": "_id",  # Matching field in users
                "as": "friend"
            }
        },
        {"$unwind": "$friend"}  # Convert friend array to an object
        ]
        friends = await self.db.friends.aggregate(pipeline).to_list(100)
        friends = [FriendResponse(**friend) for friend in friends]
        return friends
    
    async def delete_friend(self, _id: str) -> bool:
        result = await self.db.friends.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1
    
    async def delete_all_friends(self, user_id: str) -> bool:
        user_id = ObjectId(user_id)
        result = await self.db.friends.delete_many({"user_id": user_id})
        return result.deleted_count > 0