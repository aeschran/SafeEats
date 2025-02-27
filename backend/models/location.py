from typing import List
class Location:
    def __init__(self, coordinates: List[float]):
        self.type = "Point"
        self.coordinates = coordinates
    def to_dict(self):
        return {
            "type": self.type,
            "coordinates": self.coordinates
        }