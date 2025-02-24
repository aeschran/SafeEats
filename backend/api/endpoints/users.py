from fastapi import APIRouter, Depends, Body
from motor.motor_asyncio import AsyncIOMotorDatabase
from schemas.user import UserCreate, UserResponse, UserChangePassword
from services.user_service import UserService
from core.security import credentials_exception
from services.jwttoken import verify_token, get_token

router = APIRouter(tags=["Users"])

user_service = UserService()

@router.get("/currentUser")
async def current_user(current_user: UserResponse = Depends(user_service.get_current_user)): 
    print("currentUser endpoint called")
    return {"user": current_user}  # current_user is already the user object

@router.get("")
async def get_users_endpoint(token: str = Depends(get_token), 
    user_service: UserService = Depends()):
    access = verify_token(token, credentials_exception)
    return await user_service.get_users()

@router.post("")
async def create_user_endpoint(user: UserCreate):
    return await user_service.create_new_user(user)

@router.get("/{email}")
async def get_user_endpoint(email: str, 
    token: str = Depends(get_token), 
    user_service: UserService = Depends()):
    
    access = verify_token(token, credentials_exception)

    return await user_service.get_user_by_email(email)

@router.delete("/{_id}")
async def delete_user_endpoint(_id: str):
    return await user_service.delete_user(_id)

@router.post("/change_password")
async def change_password_endpoint(
user: UserChangePassword):
    # TODO: readd token stuff
    # access = verify_token(token, credentials_exception)
    result = await user_service.change_user_password(user)
    return result

