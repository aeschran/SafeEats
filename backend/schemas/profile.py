from pydantic import BaseModel, EmailStr
from schemas.preference import PreferenceCreate
from typing import List

class ProfileCreate(BaseModel):

    bio: str
    friend_count: int
    review_count: int
    image : str
    preferences: List[PreferenceCreate] = []

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
    review_count: int
    username: str
    image: str | None = None
    preferences: List[PreferenceCreate] = []
    is_following: bool | None = None
    is_requested: bool | None = None
    # image: str

class ProfileSearchResponse(BaseModel):
    id: str
    name: str
    username: str
