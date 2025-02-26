from bson import ObjectId
from pydantic import BaseModel, Field
from utils.pyobjectid import PyObjectId
from schemas.user import UserCreate, UserResponse

class FriendCreate(BaseModel):
    notification_id: str
    user_id: str
    friend_id: str

class FriendResponse(BaseModel):
    # id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: PyObjectId
    friend_id: PyObjectId
    friend_since: float
    username: str

    class Config:
        arbitrary_types_allowed = True