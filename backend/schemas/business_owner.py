from pydantic import BaseModel, EmailStr
from typing import Optional


class BusinessOwnerCreate(BaseModel):

    name: str
    email: EmailStr
    password: str
    phone_number: str
    isVerified: bool = False

class BusinessOwnerResponse(BaseModel):
    name: str
    email: EmailStr
    phone_number: str
    isVerified: bool
    
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[EmailStr] = None

