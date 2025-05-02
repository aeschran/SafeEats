from models.ocr_results import OcrResults
from bson import ObjectId
class Menu:
    def __init__(self, business_id: ObjectId, ocr_results: OcrResults, image_url: str, created_at: str, image_width: int, image_height: int, is_official: bool = False):
        self.business_id = business_id
        self.ocr_results = ocr_results
        self.image_url = image_url
        self.created_at = created_at
        self.image_width = image_width
        self.image_height = image_height
        self.is_official = False

    def to_dict(self):
        return {
            "business_id": self.business_id,
            "ocr_results": self.ocr_results,
            "image_url": self.image_url,
            "created_at": self.created_at,
            "image_width": self.image_width,
            "image_height": self.image_height,
            "is_official": self.is_official
        }