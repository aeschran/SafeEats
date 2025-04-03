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

class CollectionEdit(BaseModel):
    collection_id: PyObjectId = Field(..., alias="collection_id")
    name: str

class CollectionRemoveBusiness(BaseModel):
    collection_id: PyObjectId = Field(..., alias="collection_id")
    business_id: PyObjectId = Field(..., alias="business_id")
