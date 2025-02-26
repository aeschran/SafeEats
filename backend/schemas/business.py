from pydantic import BaseModel, field_validator
from typing import Optional, Dict, List
from schemas.location import LocationCreate
from utils.pyobjectid import PyObjectId
    

class BusinessCreate(BaseModel):
    name: str
    owner_id: Optional[PyObjectId] = None
    website: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[str] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    location: Optional[LocationCreate] = None
    dietary_restrictions: List[str] = []

class BusinessResponse(BaseModel):
    name: str
    website: Optional[str] = None
    description: Optional[str] = None
    cuisines: List[str] = []
    menu: Optional[str] = None
    address: Optional[str] = None
    dietary_restrictions: List[str] = []
