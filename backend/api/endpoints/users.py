from fastapi import APIRouter, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from db.init_db import connect_db
from schemas.user import UserCreate
from services.user_service import create_new_user, get_user_by_email, get_users

router = APIRouter(tags=["Users"])

async def get_db() -> AsyncIOMotorDatabase:
    return connect_db()

@router.get("")
async def get_users_endpoint(db: AsyncIOMotorDatabase = Depends(get_db)):
    return await get_users()

@router.post("")
async def create_user_endpoint(user: UserCreate, db: AsyncIOMotorDatabase = Depends(get_db)):
    return await create_new_user(user)

@router.get("/{email}")
async def get_user_endpoint(email: str, db: AsyncIOMotorDatabase = Depends(get_db)):
    return await get_user_by_email(email)