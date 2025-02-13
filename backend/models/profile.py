# models/user.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

class Profile:
    def __init__(self, name: str, bio: str, friend_count: int, review_count: int):
        self.name = name
        self.bio = bio
        self.friend_count = friend_count
        self.review_count = review_count
    def to_dict(self):
        return {  
            "name": self.name,
            "bio": self.bio,
            "friend_count": self.friend_count,
            "review_count": self.review_count,
        }