from pydantic import BaseModel, EmailStr
from utils.pyobjectid import PyObjectId

class BusinessOwnerCreate(BaseModel):

    name: str
    email: EmailStr
    password: str
    isVerified: bool = False

class BusinessOwnerResponse(BaseModel):
    name: str
    email: EmailStr
    isVerified: bool

