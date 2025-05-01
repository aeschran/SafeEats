# models/user.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
from schemas.preference import PreferenceCreate
from typing import List

class Profile:
    def __init__(self, name: str, bio: str, friend_count: int, review_count: int, image: str, preferences: List[PreferenceCreate] = [], trusted_reviewer: bool = False):
        self.name = name
        self.bio = bio
        self.friend_count = friend_count
        self.review_count = review_count
        self.image = image
        self.preferences = preferences
        self.trusted_reviewer = trusted_reviewer

    def to_dict(self):
        return {  
            "name": self.name,
            "bio": self.bio,
            "friend_count": self.friend_count,
            "review_count": self.review_count,
            "preferences": [preference.model_dump() for preference in self.preferences],
            "trusted_reviewer": self.trusted_reviewer,
        }
    
    def get_image(self):
        return {"image": self.image}
        