from pydantic import BaseModel, EmailStr
from typing import Optional
from schemas.preference import PreferenceCreate
from typing import List

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    username: str
    preferences: List[PreferenceCreate] = []

class UserResponse(BaseModel):
    name: str
    email: EmailStr
    username: str
    preferences: List[PreferenceCreate] = []
    
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None
    
class ForgotPasswordRequest(BaseModel):
    email: str



