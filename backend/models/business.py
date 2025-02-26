from bson import ObjectId
from typing import Optional, List, Dict

class Business:
    def __init__(self, name, owner_id: Optional[ObjectId] = None, website: Optional[str] = None, phone_number: Optional[str] = None, description: Optional[str] = None, cuisines: List[str] = [], menu: Optional[str] = None, address: Optional[str] = None, location: Dict[str, float] = {}, dietary_restrictions: List[str] = []):
        self.name = name
        self.owner_id = owner_id
        self.website = website
        self.description = description
        self.cuisines = cuisines
        self.menu = menu
        self.address = address
        self.location = location
        self.dietary_restrictions = []
    def to_dict(self):
        return {
            "name": self.name,
            "owner_id": str(self.owner_id),
            "website": self.website,
            "description": self.description,
            "cuisines": self.cuisines,
            "menu": self.menu,
            "address": self.address,
            "location": self.location,
            "dietary_restrictions": self.dietary_restrictions
        }