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
            "name": self.name,
            "owner_id": str(self.owner_id),
            "website": self.website,
            "description": self.description,
            "cuisines": self.cuisines,
            "menu": self.menu,
            "address": self.address,
            "location": self.location.to_dict(),
            "dietary_restrictions": self.dietary_restrictions
        }
    
class BusinessCollectionEntry:
    def __init__(self, business_id: str, business_name: str, business_description: str, business_address: str):
        self.business_id = business_id
        self.business_name = business_name
        self.business_description = business_description
        self.business_address = business_address
    
    def to_dict(self) -> Dict:
        return {
            "business_id": self.business_id,
            "business_name": self.business_name,
            "business_description": self.business_description,
            "business_address": self.business_address
        }