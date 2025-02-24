from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    username: str

class UserChangePassword(BaseModel):
    password: str
    username: str
    new_password: str

class UserResponse(BaseModel):
    name: str
    email: EmailStr
    username: str
    
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None
