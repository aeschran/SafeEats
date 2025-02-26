from pydantic import BaseModel

class LocationCreate(BaseModel):
    lat: float
    lon: float

class LocationResponse(BaseModel):
    lat: float
    lon: float