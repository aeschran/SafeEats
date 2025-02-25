from datetime import datetime, timedelta
from jose import JWTError, jwt
from schemas.user import TokenData
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
RESET_TOKEN_EXPIRE_MINUTES = 60

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_reset_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=RESET_TOKEN_EXPIRE_MINUTES)  
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token:str,credentials_exception):
 try:
     payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
     username: str = payload.get("sub")
     if username is None:
         raise credentials_exception
     token_data = TokenData(username=username)
     return token_data
 except JWTError:
     raise credentials_exception

def verify_reset_token(token: str, credentials_exception):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")  # Use email for password reset
        if email is None:
            raise credentials_exception
        return email 
    except JWTError:
        raise credentials_exception

 
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
oauth2_scheme_token = OAuth2PasswordBearer(tokenUrl="token")

async def get_token(token: str = Depends(oauth2_scheme)):
    return token

async def get_token_protected(token: str = Depends(oauth2_scheme_token)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    print("hola")
    token_data = verify_token(token, credentials_exception)
    if token_data is None:
        raise credentials_exception
    return token_data