from bson import ObjectId
from typing import Optional, List, Dict
from models.preference import Preference
from models.cuisine import Cuisine
from models.location import Location

class Business:
    def __init__(self, name, location: Location, owner_id: Optional[ObjectId] = None, website: Optional[str] = None, tel: Optional[str] = None, description: Optional[str] = None, cuisines: List[int] = [], menu: Optional[str] = None, address: Optional[str] = None, dietary_restrictions: List[str] = [], avg_rating: Optional[float] = 0.0):
        self.name = name
        self.owner_id = owner_id
        self.website = website
        self.tel = tel
        self.description = description
        self.cuisines = cuisines
        self.menu = menu
        self.address = address
        self.location = location
        self.dietary_restrictions = []
        self.avg_rating = avg_rating
        
    def to_dict(self):
        return {
            "name": self.name,
            "owner_id": str(self.owner_id),
            "website": self.website,
            "tel": self.tel,
            "description": self.description,
            "cuisines": self.cuisines,
            "menu": self.menu,
            "address": self.address,
            "location": self.location.to_dict(),
            "dietary_restrictions": self.dietary_restrictions,
            "avg_rating": self.avg_rating
        }