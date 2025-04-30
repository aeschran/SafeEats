from pydantic import BaseModel, Field
from typing import Optional
from utils.pyobjectid import PyObjectId 
from bson import ObjectId

class CommentCreate(BaseModel):
    review_id: str = Field(...)
    commenter_id: str = Field(...)
    is_business: bool = Field(...)
    comment_content: str = Field(...)

class CommentResponse(BaseModel):
    id: str = Field(..., alias="_id")
    review_id: str
    commenter_id: str
    commenter_username: str
    is_business: bool
    comment_content: str
    comment_timestamp: float

    class Config:
        allow_population_by_field_name = True
        json_encoders = {ObjectId: str}
