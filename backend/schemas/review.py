from bson import ObjectId
from pydantic import BaseModel, Field
from utils.pyobjectid import PyObjectId
from schemas.user import UserCreate, UserResponse
from schemas.preference import PreferenceCreate
from typing import Optional, List

class ReviewCreate(BaseModel):
    business_id: str
    # business_name: str
    user_id: str
    # user_name: str
    rating: int
    # review_timestamp: float
    review_content: str
    # review_image: Optional[str] = None 
    meal: str
    accommodations: List[PreferenceCreate]

class ReviewImage(BaseModel):
    review_id: str
    review_image: str

class ReviewResponse(BaseModel):
    business_id: PyObjectId
    user_id: PyObjectId
    friend_since: float
    username: str
    name: str
    meal: str
    accomodations: List[PreferenceCreate]

class ReviewAddVote(BaseModel):
    review_id: PyObjectId
    user_id: PyObjectId
    vote: int

    class Config:
        arbitrary_types_allowed = True

class ReportReview(BaseModel):
    review_id: str
    user_name: str
    message: str

    class Config:
        arbitrary_types_allowed = True