from fastapi import APIRouter, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from schemas.business_owner import BusinessOwnerCreate
from services.business_owner_service import BusinessOwnerService
from core.security import credentials_exception
from services.jwttoken import verify_token, get_token

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

@router.get("/{email}")
async def get_business_owner_endpoint(email: str, token: str = Depends(get_token), 
    business_owner_service: BusinessOwnerService = Depends()):
    access = verify_token(token, credentials_exception)
    return await business_owner_service.get_business_owner_by_email(email)

@router.delete("/{_id}")
async def delete_business_owner_endpoint(_id: str):
    return await business_owner_service.delete_business_owner(_id)

@router.patch("/{owner_id}/verify")
async def verify_business_owner_endpoint(owner_id: str):
    
    # endpoint for admin to validate a business owner
    return await business_owner_service.verify_business_owner(owner_id)
    