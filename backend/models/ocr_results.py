from typing import List
class OcrResults:
    def __init__(self, text: str, bbox: List[int], conflict: str):
        self.text = text
        self.bbox = bbox
        self.conflict = conflict
    
    def to_dict(self):
        return {
            "text": self.text,
            "bbox": self.bbox,
            "conflict": self.conflict
        }