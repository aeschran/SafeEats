from typing import Annotated
from fastapi import APIRouter, Depends, Body, Request
from fastapi.security import OAuth2PasswordBearer
from motor.motor_asyncio import AsyncIOMotorDatabase
from schemas.user import UserCreate, UserResponse, UserChangePassword
from services.user_service import UserService
from core.security import credentials_exception
from services.jwttoken import verify_token, get_token, get_token_protected

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

@router.get("/{username}")
async def get_user_endpoint(username: str):
    return await user_service.get_user_by_username(username)

@router.delete("/{_id}")
async def delete_user_endpoint(_id: str):
    return await user_service.delete_user(_id)



@router.post("/change_password")
async def change_password_endpoint(request: Request,
user: UserChangePassword):
    # TODO: readd token stuff
    headers = request.headers
    token = headers.get("Authorization")
    print("Token:", token)
    # access = verify_token(token, credentials_exception)
    result = await user_service.change_user_password(user)
    return result   

