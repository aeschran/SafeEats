from pydantic import BaseModel

class LocationCreate(BaseModel):
    type: str
    coordinates: list

class LocationResponse(BaseModel):
    type: str
    coordinates: list