from pydantic import BaseModel, field_validator, Field
from typing import Optional, Dict, List
from schemas.location import LocationCreate
from utils.pyobjectid import PyObjectId
from schemas.preference import PreferenceResponse
from schemas.cuisine import CuisineResponse, CuisineCreate

class SocialMedia(BaseModel):
    facebook_id: Optional[str] = None
    instagram: Optional[str] = None
    twitter: Optional[str] = None

class BusinessCreate(BaseModel):
    name: str
    owner_id: Optional[PyObjectId] = None
    website: Optional[str] = None
    tel: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[int] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    location: Optional[LocationCreate] = None
    dietary_restrictions: List[PreferenceResponse] = []
    avg_rating: Optional[float] = 0.0
    social_media: Optional[SocialMedia] = None

class BusinessResponse(BaseModel):
    id: PyObjectId = Field(..., alias="_id")
    name: str
    website: Optional[str] = None
    tel: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[int] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    dietary_restrictions: List[PreferenceResponse] = []
    avg_rating: Optional[float] = 0.0
    social_media: Optional[SocialMedia] = None

class BusinessSearch(BaseModel):
    lat: float
    lon: float
    query: Optional[str] = "restaurant"
    cuisines: Optional[List[str]] = []
    dietary_restrictions: Optional[List[PreferenceResponse]] = []
    radius: Optional[int] = 5000

class LatLon(BaseModel):
    lat: float
    lon: float


# This class is designed for maps
class BusinessAndLocationResponse(BaseModel):
    id: PyObjectId = Field(..., alias="_id")
    name: str
    website: Optional[str] = None
    description: Optional[str] = None
    menu: Optional[str] = None
    cuisines: List[int] = []
    address: Optional[str] = None
    dietary_restrictions: List[PreferenceResponse] = []
    location: LatLon
    avg_rating: Optional[float] = 0.0
    tel: Optional[str] = None

class BusinessCollectionEntry(BaseModel):
    business_id: str
    business_name: str
    business_description: str
    business_address: str

class BusinessAddPreferences(BaseModel):
    dietPref: List[str]
    allergy: List[str]

class EditBusiness(BaseModel):
    website: Optional[str] = None
    tel: Optional[str] = None
    facebook_id: Optional[str] = None
    instagram: Optional[str] = None
    twitter: Optional[str] = None
