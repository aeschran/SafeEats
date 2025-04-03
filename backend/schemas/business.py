from pydantic import BaseModel, field_validator, Field
from typing import Optional, Dict, List
from schemas.location import LocationCreate
from utils.pyobjectid import PyObjectId
from schemas.preference import PreferenceResponse
from schemas.cuisine import CuisineResponse, CuisineCreate

class BusinessCreate(BaseModel):
    name: str
    owner_id: Optional[str] = None
    website: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[int] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    location: Optional[LocationCreate] = None
    dietary_restrictions: List[PreferenceResponse] = []

class BusinessResponse(BaseModel):
    id: PyObjectId = Field(..., alias="_id")
    owner_id: Optional[str] = None
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