from fastapi import APIRouter
from services.business_search import BusinessSearchService

router = APIRouter(tags=["Business Search"])

business_search_service = BusinessSearchService()

@router.get("")
async def search_businesses_endpont(query: str = "coffee", near: str = "West Lafayette, IN", limit: int = 10):
    return business_search_service.search_by_query()