from fastapi import APIRouter, HTTPException
from services.business_service import BusinessService

router = APIRouter(tags=["Businesses"])

business_service = BusinessService()

@router.get("/{business_id}/average-rating")
async def get_avg_rating_endpoint(business_id: str):
    avg_rating = await business_service.get_average_rating(business_id)
    
    if avg_rating is None:
        raise HTTPException(status_code=404, detail="Business not found or no rating available")
    
    return avg_rating

@router.get("/{business_id}/total-reviews")
async def total_reviews_endpoint(business_id: str):
    total_reviews = await business_service.get_review_count(business_id)
    
    if total_reviews is None:
        raise HTTPException(status_code=404, detail="Business not found or no reviews available")
    
    return total_reviews

@router.put("/{business_id}/update-average-rating")
async def update_average_rating_endpoint(business_id: str):
    avg_rating = await business_service.update_average_rating(business_id)
    
    if avg_rating is None:
        raise HTTPException(status_code=404, detail="Business not found or no reviews available")
    
    return avg_rating