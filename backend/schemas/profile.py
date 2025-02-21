from pydantic import BaseModel, EmailStr

class ProfileCreate(BaseModel):

    bio: str
    friend_count: int
    review_count: int

class ProfileResponse(BaseModel):
    name: str
    bio: str
    friend_count: int
    review_count: int

