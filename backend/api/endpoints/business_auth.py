from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from services.business_owner_service import BusinessOwnerService, verify_password
from schemas.password_reset import ForgotPasswordRequest, VerifyCodeRequest, ResetPasswordRequest
from core.security import credentials_exception


from services.jwttoken import create_access_token, verify_token, get_token, create_reset_token, verify_reset_token
from fastapi.security import OAuth2PasswordRequestForm


router = APIRouter(tags=["Business Auth"])

business_owner_service = BusinessOwnerService()    



@router.get("/email/{email}")
async def get_email_endpoint(email: str, token: str = Depends(get_token), 
    business_owner_service: BusinessOwnerService = Depends()):
    
    access = verify_token(token, credentials_exception)
    
    business_owner = await business_owner_service.get_business_owner_by_email(email)
    
    return business_owner

@router.post("/login")
async def login(request: OAuth2PasswordRequestForm = Depends()):
    
    business_owner = await business_owner_service.get_business_owner_by_email(request.username)  
    
    if not business_owner:
        raise HTTPException(status_code=400, detail="Business owner not found")
        
    if not verify_password(request.password, business_owner["password"]):
        raise HTTPException(status_code=400, detail="Invalid password")
    
    
    # Generate access token with the business owner's email
    access_token = create_access_token(data={"sub": business_owner["email"]})

    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest):
    return await business_owner_service.forgot_password(request.email)

@router.post("/verify-reset-code")
async def verify_reset_code(request: VerifyCodeRequest):
    return await business_owner_service.verify_code(request.email, request.code)


@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    return await business_owner_service.reset_password(request.email, request.code, request.new_password)

