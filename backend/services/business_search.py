import requests
from core.config import settings

class BusinessSearchService:
    def __init__(self, query: str = "coffee", near: str = "West Lafayette, IN", limit: int = 10):
        self.query = query
        self.near = near
        self.limit = limit

    def search_by_query(self):
        url = "https://api.foursquare.com/v3/places/search"
        params = {
            "near": self.near,
            "query": self.query,
            "near": self.near
        }
        headers = {
            "accept": "application/json",
            "Authorization": settings.FOURSQUARE_SECRET
        }

        response = requests.get(url, params=params, headers=headers)
        print(response.url)

        return response.json()

