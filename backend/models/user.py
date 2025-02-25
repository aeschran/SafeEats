# models/user.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

class User:
    def __init__(self, name: str, email: str, password: str, username: str):
        self.name = name
        self.email = email
        self.password = password
        self.username = username
        

    def to_dict(self):
        return {  
            "name": self.name,
            "email": self.email,
            "password": self.password,
            "username": self.username,
        }