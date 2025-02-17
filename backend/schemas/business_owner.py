from pydantic import BaseModel, EmailStr
from utils.pyobjectid import PyObjectId
from typing import Optional


class BusinessOwnerCreate(BaseModel):

    name: str
    email: EmailStr
    password: str
    isVerified: bool = False

class BusinessOwnerResponse(BaseModel):
    name: str
    email: EmailStr
    isVerified: bool
    
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[EmailStr] = None

