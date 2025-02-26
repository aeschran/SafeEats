from fastapi import APIRouter
from services.business_search import BusinessSearchService

router = APIRouter(tags=["Business Search"])

business_search_service = BusinessSearchService()

@router.get("")
async def search_businesses_endpoint(lat: float, lon: float, limit: int = 10, query: str = "coffee"):
    response = await business_search_service.search_by_lat_long(lat, lon, query)
    return response