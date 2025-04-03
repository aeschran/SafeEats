from bson import ObjectId
from typing import Optional, List, Dict
from models.preference import Preference
from models.cuisine import Cuisine
from models.location import Location

class Business:
    def __init__(self, name, location: Location, owner_id: Optional[ObjectId] = None, website: Optional[str] = None, phone_number: Optional[str] = None, description: Optional[str] = None, cuisines: List[int] = [], menu: Optional[str] = None, address: Optional[str] = None, dietary_restrictions: List[str] = []):
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
            "owner_id": str(self.owner_id) if self.owner_id else None,
            "name": self.name,
            "website": self.website,
            "description": self.description,
            "cuisines": self.cuisines,
            "menu": self.menu,
            "address": self.address,
            "location": self.location.to_dict(),
            "dietary_restrictions": self.dietary_restrictions
        }