from bson import ObjectId
from typing import List

class Range:
    def __init__(self, min: int, max: int):
        self.min = min
        self.max = max
    def to_dict(self):
        return {
            "min": self.min,
            "max": self.max
        }
class Cuisine:
    def __init__(self, name:str, path:str, ranges:List[Range]):
        self.name = name
        self.ranges = ranges
    def to_dict(self):
        return {
            "name": self.name,
            "path": self.path,
            "ranges": [range.to_dict() for range in self.ranges]
        }