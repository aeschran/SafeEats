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
        # user_id = ObjectId(user_id)

        friends = await self.db.friends.aggregate([
            {
                "$match": { "user_id": user_id }
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
        
        for friend in friends[0]["friends"]:
            friend_id = friend["friend_id"]
            print(friend_id)
            user_data = await self.db.users.find_one({"_id": ObjectId(friend_id)}, {"name": 1, "username": 1})
            if user_data:
                friend["name"] = user_data["name"]
                print(friend["name"])
                friend["username"] = user_data["username"]
                print(friend["username"])
            print(user_data)

        # friends = await self.db.friends.aggregate(pipeline).to_list(100)
        
        # friends = [FriendResponse(**friend) for friend in friends]
        # if friends:
        #     print(":")
        print(friends[0]["friends"][0])
        return friends
    
    async def delete_friend(self, _id: str) -> bool:
        result = await self.db.friends.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1
    
    async def delete_all_friends(self, user_id: str) -> bool:
        user_id = ObjectId(user_id)
        result = await self.db.friends.delete_many({"user_id": user_id})
        return result.deleted_count > 0