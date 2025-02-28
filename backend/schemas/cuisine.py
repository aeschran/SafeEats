from pydantic import BaseModel
from typing import List

class Range(BaseModel):
    min: int
    max: int

class CuisineCreate(BaseModel):
    name: str
    ranges: List[Range]
class CuisineResponse(BaseModel):
    name: str
    ranges: List[Range]