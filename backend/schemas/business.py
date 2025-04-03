from pydantic import BaseModel, field_validator, Field
from typing import Optional, Dict, List
from schemas.location import LocationCreate
from utils.pyobjectid import PyObjectId
from schemas.preference import PreferenceResponse
from schemas.cuisine import CuisineResponse, CuisineCreate

class BusinessCreate(BaseModel):
    name: str
    owner_id: Optional[PyObjectId] = None
    website: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[int] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    location: Optional[LocationCreate] = None
    dietary_restrictions: List[PreferenceResponse] = []

class BusinessResponse(BaseModel):
    id: PyObjectId = Field(..., alias="_id")
    name: str
    website: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[int] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    dietary_restrictions: List[PreferenceResponse] = []


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