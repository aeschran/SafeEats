from models.ocr_results import OcrResult
class Menu:
    def __init__(self, ocr_results: OcrResult, image_url: str, created_at: str):
        self.ocr_results = ocr_results
        self.image_url = image_url
        self.created_at = created_at

    def to_dict(self):
        return {
            "ocr_results": self.ocr_results.to_dict(),
            "image_url": self.image_url,
            "created_at": self.created_at
        }