from fastapi import APIRouter
from services.business_search import BusinessSearchService
from schemas.business import BusinessSearch

router = APIRouter(tags=["Business Search"])

business_search_service = BusinessSearchService()

@router.post("")
async def search_businesses_endpoint(business_search: BusinessSearch):
    response = await business_search_service.search_operator(business_search)
    return response

@router.get("/get/{business_id}")
async def get_business_by_id_endpoint(business_id: str):
    """
    Endpoint to get a business by its ID
    """
    print("here")
    response = await business_search_service.get_business_by_id(business_id)
    if response is None:
        return {"error": "Business not found"}
    return response