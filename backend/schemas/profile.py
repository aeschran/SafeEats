from pydantic import BaseModel, EmailStr
from schemas.preference import PreferenceCreate
from typing import List, Optional

class ProfileCreate(BaseModel):
    name: Optional[str]
    bio: str
    friend_count: int
    review_count: int
    image : str
    preferences: List[PreferenceCreate] = []

class ProfileUpdate(BaseModel):
    name: Optional[str]
    bio: Optional[str]
    image: Optional[str] 


class ProfileResponse(BaseModel):
    name: str
    bio: str
    friend_count: int
    review_count: int
    username: str
    image: str | None = None
    preferences: List[PreferenceCreate] = []

class OtherProfileResponse(BaseModel):
    name: str
    bio: str
    friend_count: int
    review_count: int = 0
    username: str
    image: str | None = None
    preferences: List[PreferenceCreate] = []
    is_following: bool | None = None
    is_requested: bool | None = None
    is_trusted: bool = False
    # image: str

class ProfileSearchResponse(BaseModel):
    id: str
    name: str
    username: str
