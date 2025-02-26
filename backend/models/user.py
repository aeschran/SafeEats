# models/user.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

class User:
    def __init__(self, name: str, email: str, phone: str, password: str, username: str, bio: str = "", friend_count: int = 0, review_count: int = 0):
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
        self.username = username
        self.bio = bio
        self.friend_count = friend_count
        self.review_count = review_count
        

    def to_dict(self):
        return {  
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "password": self.password,
            "username": self.username,
            "bio": self.bio,
            "friend_count": self.friend_count,
            "review_count": self.review_count
        }