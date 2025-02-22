from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from services.business_owner_service import BusinessOwnerService, verify_password
from core.security import credentials_exception


from services.jwttoken import create_access_token, verify_token, get_token
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter(tags=["Business Auth"])

business_owner_service = BusinessOwnerService()    

@router.get("/email/{email}")
async def get_email_endpoint(email: str, token: str = Depends(get_token), 
    user_service: BusinessOwnerService = Depends()):
    
    access = verify_token(token, credentials_exception)
    
    business_owner = await user_service.get_business_owner_by_email(email)
    if not business_owner:
        raise HTTPException(status_code=404, detail="Business owner not found")
    
    return business_owner

@router.post("/login")
async def login(request: OAuth2PasswordRequestForm = Depends()):
    
    business_owner = await business_owner_service.get_business_owner_by_email(request.username)  
    
    if not business_owner:
        raise HTTPException(status_code=400, detail="No existing account for entered email")
        
    if not verify_password(request.password, business_owner["password"]):
        raise HTTPException(status_code=400, detail="Invalid password")
    
    
    # Generate access token with the business owner's email
    access_token = create_access_token(data={"sub": business_owner["email"]})

    return {"access_token": access_token, "token_type": "bearer"}