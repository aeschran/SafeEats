# models/business_owner.py
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

class BusinessOwner:
    def __init__(self, name: str, email: str, phone: str, password: str, isVerified: bool = False):
        self.name = name
        self.email = email
        self.phone = phone 
        self.password = password
        self.isVerified = isVerified

    def to_dict(self):
        return {  
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "password": self.password,
            "isVerified": self.isVerified
        }