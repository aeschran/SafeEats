from pydantic import BaseModel, EmailStr
from core.utils import PyObjectId

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    name: str
    email: EmailStr