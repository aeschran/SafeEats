from bson import ObjectId
from typing import Optional, List, Dict
from schemas.business import SocialMedia, Hours, Day
from models.preference import Preference
from models.cuisine import Cuisine
from models.location import Location
from pydantic import BaseModel

class Business:
    def __init__(self, name, location: Location, owner_id: Optional[ObjectId] = None, website: Optional[str] = None, tel: Optional[str] = None, description: Optional[str] = None, cuisines: List[int] = [], menu: Optional[str] = None, address: Optional[str] = None, dietary_restrictions: List[str] = [], avg_rating: Optional[float] = 0.0, social_media: Optional[SocialMedia] = None, price: Optional[int] = None, hours: Optional[Hours] = None):
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
        self.social_media = social_media
        self.price = price
        self.hours = hours
        
        
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
            "avg_rating": self.avg_rating,
            "social_media": self.social_media.dict() if isinstance(self.social_media, BaseModel) else self.social_media,

            # "social_media": self.social_media,
            "price": self.price,
            "hours": self.hours.model_dump() if self.hours else None
            # "hours": self.hours
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