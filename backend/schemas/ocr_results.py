from pydantic import BaseModel, Field
from utils.pyobjectid import PyObjectId
from typing import List

class OcrResult(BaseModel):
    bbox: List[List[int]]
    conflict: List[str]