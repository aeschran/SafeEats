from pydantic import BaseModel, EmailStr
from typing import Optional

class VerificationCall(BaseModel):
    owner_id: str
    business_phone: str


class VerifyBusinessOwner(BaseModel):
    owner_id: str
    business_id: str
    code: str
    expires_at: str