from fastapi import APIRouter, Depends, Query
from motor.motor_asyncio import AsyncIOMotorDatabase, AsyncIOMotorClient
from schemas.profile import ProfileCreate, ProfileSearchResponse
from services.user_profile_service import UserProfileService
from typing import List

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

@router.get("/search", response_model=List[ProfileSearchResponse])
async def get_profile_search_endpoint(
    _id: str,
    query: str = Query(..., min_length=1)
    ):
    return await user_profile_service.get_profile_search(_id, query)

@router.get("/{_id}")
async def get_user_profile_endpoint(_id: str):
    return await user_profile_service.get_user_profile(_id)





