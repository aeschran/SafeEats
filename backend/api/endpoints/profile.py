from fastapi import APIRouter, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from schemas.profile import ProfileCreate
from services.user_profile_service import UserProfileService

router = APIRouter(tags=["Profile"])

user_profile_service = UserProfileService()

# @router.get("")
# async def get_users_endpoint():
#     return await user_service.get_users()

@router.get("/{_id}/other/{friend_id}")
async def get_other_user_profile_endpoint(_id:str, friend_id: str):
    return await user_profile_service.get_other_user_profile(_id, friend_id)

@router.put("/create/{_id}")
async def create_user_profile_endpoint(_id: str, profile: ProfileCreate):
    return await user_profile_service.create_new_profile(_id, profile)

@router.get("/{_id}")
async def get_user_profile_endpoint(_id: str):
    return await user_profile_service.get_user_profile(_id)

