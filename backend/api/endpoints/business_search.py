from fastapi import APIRouter
from services.business_search import BusinessSearchService
from schemas.business import BusinessSearch

router = APIRouter(tags=["Business Search"])

business_search_service = BusinessSearchService()

@router.post("")
async def search_businesses_endpoint(business_search: BusinessSearch):
    response = await business_search_service.search_by_lat_long(business_search)
    return response