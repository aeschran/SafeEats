from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from services.user_service import UserService, verify_password
from core.security import credentials_exception


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

    return {"access_token": access_token, "token_type": "bearer"}