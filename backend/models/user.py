# models/user.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
from schemas.preference import PreferenceCreate
from typing import List
class User:
    def __init__(self, name: str, email: str, password: str, username: str, preferences: List[PreferenceCreate] = []):
        self.name = name
        self.email = email
        self.password = password
        self.username = username
        self.preferences = preferences

    def to_dict(self):
        return {  
            "name": self.name,
            "email": self.email,
            "password": self.password,
            "username": self.username,
            "preferences": [preference.to_dict() for preference in self.preferences]
        }