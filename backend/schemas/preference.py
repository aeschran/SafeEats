from pydantic import BaseModel

class PreferenceCreate(BaseModel):
    preference: str
    preference_type: str

class PreferenceResponse(BaseModel):
    preference: str
    preference_type: str