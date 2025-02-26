class Location:
    def __init__(self, lat: float, lon: float):
        self.lat = lat
        self.lon = lon
    def to_dict(self):
        return {
            "lat": self.lat,
            "lon": self.lon
        }