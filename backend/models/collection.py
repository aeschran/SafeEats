from pydantic import BaseModel
from typing import Optional, Dict, List
from utils.pyobjectid import PyObjectId

class Collection:
    def __init__(self, name, user_id: str, businesses: List[Dict[str, str]] = []):
        self.name = name
        self.user_id = user_id
        self.businesses = businesses
    def to_dict(self):
        return {
            "name": self.name,
            "user_id": self.user_id,
            "businesses": self.businesses
        }