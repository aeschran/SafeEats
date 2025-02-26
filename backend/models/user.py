# models/user.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

# class User:
#     def __init__(self, name: str, email: str, phone: str, password: str, username: str):
#         self.name = name
#         self.email = email
#         self.phone = phone
#         self.password = password
#         self.username = username

class User:
    def __init__(self, name: str, email: str, phone: str, password: str, username: str, bio: str = "", friend_count: int = 0, review_count: int = 0):
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
        self.username = username
        

    def to_dict(self):
        return {  
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "password": self.password,
            "username": self.username,
        }