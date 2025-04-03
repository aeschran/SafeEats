from fastapi import APIRouter, Depends, Query
from motor.motor_asyncio import AsyncIOMotorDatabase
from schemas.business_owner import BusinessOwnerCreate, BusinessOwnerResponse
from schemas.business import BusinessResponse
from schemas.business_verification import VerificationCall, VerifyBusinessOwner
from services.business_owner_service import BusinessOwnerService
from core.security import credentials_exception
from services.jwttoken import verify_token, get_token
from typing import List

router = APIRouter(tags=["Business Owners"])

business_owner_service = BusinessOwnerService()

@router.get("")
async def get_business_owners_endpoint(token: str = Depends(get_token), 
    business_owner_service: BusinessOwnerService = Depends()):
    access = verify_token(token, credentials_exception)
    return await business_owner_service.get_business_owners()

@router.post("")
async def create_business_owner_endpoint(business_owner: BusinessOwnerCreate):
    return await business_owner_service.create_new_business_owner(business_owner)

    
@router.get("/search", response_model=List[BusinessResponse])
async def get_business_listing_search_endpoint(
    query: str = Query(..., min_length=1)
):
    return await business_owner_service.get_business_listing_search(query)

@router.get("/listings/{_id}")
async def get_business_owner_listings(_id: str):
    return await business_owner_service.get_owner_listings(_id)

@router.get("/{email}")
async def get_business_owner_endpoint(email: str, token: str = Depends(get_token), 
    business_owner_service: BusinessOwnerService = Depends()):
    access = verify_token(token, credentials_exception)
    return await business_owner_service.get_business_owner_by_email(email)

@router.delete("/{_id}")
async def delete_business_owner_endpoint(_id: str):
    return await business_owner_service.delete_business_owner(_id)

@router.post("/verify_business_owner")
async def verify_business_owner_endpoint(request: VerificationCall):
    
    # endpoint for admin to validate a business owner
    return await business_owner_service.verify_business_owner(request.owner_id, request.business_phone)

@router.post("/verify_phone_code")
async def verify_business_owner_endpoint(request: VerifyBusinessOwner):
    
    # endpoint for admin to validate a business owner
    return await business_owner_service.verify_phone_code(request.owner_id, request.code)

