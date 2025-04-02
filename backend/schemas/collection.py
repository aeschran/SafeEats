from typing import List
from pydantic import BaseModel, Field
from utils.pyobjectid import PyObjectId
from schemas.business import BusinessCollectionEntry, BusinessResponse

class CollectionCreate(BaseModel):
    name: str
    user_id: str
    businesses: List[BusinessCollectionEntry] = []

class CollectionResponse(BaseModel):
    id: PyObjectId = Field(..., alias="_id")
    name: str
    user_id: str
    businesses: List[BusinessCollectionEntry]

class CollectionAdd(BaseModel):
    user_id: str
    collection_name: str
    business_id: PyObjectId = Field(..., alias="business_id")
