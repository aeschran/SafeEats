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
                friend = 1
                return friend
            return None
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    async def get_friends(self, user_id: str):
        user_id = ObjectId(user_id)
        # pipeline = [
        #     {
        #         "$match": {
        #             "$or": [
        #                 {"user_id": user_id},
        #                 {"friend_id": user_id}
        #             ]
        #         }
        #     },
        #     {
        #         "$addFields": {
        #             "friend_ref": {
        #                 "$cond": {
        #                     "if": {"$eq": ["$user_id", user_id]},
        #                     "then": "$friend_id",
        #                     "else": "$user_id"
        #                 }
        #             }
        #         }
        #     },
        #     {
        #         "$lookup": {
        #             "from": "users",  # Users collection
        #             "localField": "friend_ref",  # The actual friend's ID
        #             "foreignField": "_id",  # Matching field in users
        #             "as": "friend"
        #         }
        #     },
        #     {"$unwind": "$friend"},  # Convert friend array to an object
        #     {
        #         "$project": {
        #             "friend_id": 1,
        #             "user_id": 1,
        #             "username": "$friend.username",
        #             "friend_since": 1,
        #             "name": "$friend.name"
        #         }
        #     }
        # ]
        pipeline = [
        {
            "$match": {
                "$or": [
                    { "user_id": user_id },
                    { "friend_id": user_id }
                ]
            }
        },
        {
            "$project": {
                "friend_id": {
                    "$cond": {
                        "if": { "$eq": ["$user_id", user_id] },
                        "then": "$friend_id",
                        "else": "$user_id"
                    }
                },
                "user_id": {
                    "$cond": {
                        "if": { "$eq": ["$user_id", user_id] },
                        "then": "$user_id",
                        "else": "$friend_id"
                    }
                },
                "friend_since": 1
            }
        },
        {
            "$lookup": {
                "from": "users",  # Collection with user details
                "localField": "friend_id",  # Match on this field
                "foreignField": "_id",  # Match this field from the users collection
                "as": "friend"  # Store result as an array in 'friend'
            }
        },
        {
            "$unwind": "$friend"  # Unwind the 'friend' array so we get a single document
        },
        {
            "$project": {
                "user_id": 1,
                "friend_id": 1,
                "friend_since": 1,
                "username": "$friend.username",  # Get the username from the 'friend' document
                "name": "$friend.name"  # Get the name from the 'friend' document
            }
        },
        {
            "$group": {
                "_id": None,  # Group all the results together into a single document
                "friends": { "$push": "$$ROOT" }  # Push each result into an array
            }
        },
        {
            "$project": {
                "_id": 0,  # Don't include the '_id' field in the final result
                "friends": 1  # Return only the 'friends' array
            }
        }
    ]

        friends = await self.db.friends.aggregate(pipeline).to_list(100)
        friends = [
        FriendResponse(
            user_id=str(friend["user_id"]),  # Ensure user_id is converted to string
            friend_id=str(friend["friend_id"]),  # Ensure friend_id is converted to string
            friend_since=friend["friend_since"],
            username=friend["username"],
            name=friend["name"]
        )
        for friend in friends[0]["friends"]
    ]

        # friends = [FriendResponse(**friend) for friend in friends]
        return friends
    
    async def delete_friend(self, _id: str) -> bool:
        result = await self.db.friends.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1
    
    async def delete_all_friends(self, user_id: str) -> bool:
        user_id = ObjectId(user_id)
        result = await self.db.friends.delete_many({"user_id": user_id})
        return result.deleted_count > 0
    
    async def unfollow_friend(self, user_id: str, friend_id: str) -> bool:
        user_obj_id = ObjectId(user_id)
        friend_obj_id = ObjectId(friend_id)

        # delete the friend relationship
        result = await self.db.friends.delete_one({
            "user_id": user_obj_id,
            "friend_id": friend_obj_id
        })
        
        if result.deleted_count == 1:
            # decrement friend count for both users
            await self.db.users.update_one({"_id": user_obj_id}, {"$inc": {"friend_count": -1}})
            await self.db.users.update_one({"_id": friend_obj_id}, {"$inc": {"friend_count": -1}})
            return True

        return False
