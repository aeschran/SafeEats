from bson import ObjectId
from pydantic import BaseModel, Field
from utils.pyobjectid import PyObjectId

class FriendCreate(BaseModel):
    user_id: str
    friend_id: str

class FriendResponse(BaseModel):
    user_id: PyObjectId
    friend_id: PyObjectId
    friend_since: float

    class Config:
        arbitrary_types_allowed = True