from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from services.user_service import UserService, verify_password
from core.security import credentials_exception
from schemas.password_reset import ForgotPasswordRequest, VerifyCodeRequest, ResetPasswordRequest


from services.jwttoken import create_access_token, verify_token, get_token
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter(tags=["Auth"])

user_service = UserService()    

@router.get("/username/{username}")
async def get_username_endpoint(username: str, token: str = Depends(get_token), 
    user_service: UserService = Depends()):
    
    access = verify_token(token, credentials_exception)
    return await user_service.get_user_by_username(username)

@router.post("/login")
async def login(request:OAuth2PasswordRequestForm = Depends()):
    user = await user_service.get_user_by_username(request.username)

    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")
        
    if not verify_password(request.password, user["password"]):
        raise HTTPException(status_code=400, detail="Wrong password")
    
    
    access_token = create_access_token(data={"sub": user["username"] })

    return {
            "email": user["email"],
            "name": user["name"],
            "phone": user["phone"],
            "username": user["username"],
            "id": str(user["_id"]),
            "trusted_reviewer": user.get("trusted_reviewer", False),
            "access_token": access_token,
            "token_type": "bearer"
        }

@router.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest):
    return await user_service.forgot_password(request.email)

@router.post("/verify-reset-code")
async def verify_reset_code(request: VerifyCodeRequest):
    return await user_service.verify_code(request.email, request.code)


@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    return await user_service.reset_password(request.email, request.code, request.new_password)
