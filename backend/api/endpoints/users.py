from fastapi import APIRouter, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from schemas.user import UserCreate
from services.user_service import UserService

router = APIRouter(tags=["Users"])

user_service = UserService()

@router.get("")
async def get_users_endpoint():
    return await user_service.get_users()

@router.post("")
async def create_user_endpoint(user: UserCreate):
    return await user_service.create_new_user(user)

@router.get("/{email}")
async def get_user_endpoint(email: str):
    return await user_service.get_user_by_email(email)

@router.delete("/{_id}")
async def delete_user_endpoint(_id: str):
    return await user_service.delete_user(_id)
    