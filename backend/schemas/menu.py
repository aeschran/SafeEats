from pydantic import BaseModel, Field
from schemas.ocr_results import OcrResult

class MenuResponse(BaseModel):
    ocr_results: list[OcrResult]
    image_url: str
    created_at: str

    class Config:
        arbitrary_types_allowed = True