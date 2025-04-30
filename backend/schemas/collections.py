from typing import Optional, Dict, List
from pydantic import BaseModel, Field

from backend.schemas.business import BusinessCreate

class CollectionCreate(BaseModel):
    name: str
    businesses: List[BusinessCreate] = []
