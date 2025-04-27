from fastapi import APIRouter, HTTPException
from services.business_service import BusinessService, EditBusiness
from schemas.business import BusinessAddPreferences

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

@router.post("/{business_id}/addPreferences")
async def add_preferences_endpoint(business_id: str, preferences: BusinessAddPreferences):
    """
    Endpoint to add preferences to a business
    """
    if not isinstance(preferences, BusinessAddPreferences):
        raise HTTPException(status_code=400, detail="Invalid preferences format")
    
    result = await business_service.add_preferences_to_business(business_id, preferences)
    
    if result is None:
        raise HTTPException(status_code=404, detail="Business not found or failed to add preferences")
    
    return {"message": "Preferences added successfully", "result": result}

@router.put("/{business_id}/edit-business")
async def edit_business_endpoint(business_id: str, business_update: EditBusiness):
    result = await business_service.edit_business(business_id, business_update)
    
    if result is None:
        raise HTTPException(status_code=400, detail=str("Business not found or failed to update"))
    
    return {"message": "Business updated successfully", "result": result}
