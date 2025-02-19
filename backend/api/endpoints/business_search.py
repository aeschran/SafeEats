from fastapi import APIRouter, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from services.business_search import BusinessSearchService

router = APIRouter(tags=["Business Search"])

business_search_service = BusinessSearchService()

@router.get("")
async def search_businesses_endpont(query: str, near: str, limit: int = 10):
    return business_search_service.search_by_query()