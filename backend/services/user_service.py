# app/services/user_service.py
import bcrypt
from bson import ObjectId
from models.user import User
from schemas.user import UserResponse, UserCreate, UserChangePassword
from services.base_service import BaseService

from fastapi import Depends, HTTPException, status
from services.jwttoken import verify_token
from fastapi.security import OAuth2PasswordBearer
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')


def verify_password(password: str, hashed_password: str) -> bool:
    # Verify the password
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))


class UserService(BaseService):
    def __init__(self):
        super().__init__()  # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_new_user(self, user_create: UserCreate):
        # Create a new user in the database
        if await self.get_user_by_username(user_create.username):
            raise HTTPException(status_code=400, detail="Username already registered")
        if await self.get_user_by_email(user_create.email):
            raise HTTPException(status_code=400, detail="Email already registered")
        user = User(name=user_create.name, email=user_create.email, password=hash_password(
            user_create.password), username=user_create.username)
        result = await self.db.users.insert_one(user.to_dict())
        return {**user.to_dict(), "id": str(result.inserted_id)}
    
    async def delete_user(self, _id: str) -> bool:
        # Delete a user from database by email
        
        result = await self.db.users.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1

    async def get_user_by_email(self, email: str):
        # Fetch a user from the database by user_id
        user_data = await self.db.users.find_one({"email": email})
        if user_data:
            user = UserResponse(**user_data)
            return user
        return None

    async def get_user_by_username(self, username: str):
        # Fetch a user from the database by username
        user_data = await self.db.users.find_one({"username": username})
        if user_data:
            return user_data
        return None

    async def get_users(self):
        # Fetch all users from the database
        users = await self.db.users.find().to_list(100)
        users = [UserResponse(**user) for user in users]
        return users
    
    async def get_current_user(self, token: str = Depends(oauth2_scheme)): 
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
        token_data = verify_token(token, credentials_exception)  # Verify the token
        user_data = await self.get_user_by_username(token_data.username)  # Get the user
        if user_data is None:
            raise HTTPException(status_code=404, detail="User not found")
        user = UserResponse(**user_data)
        return user  # Return the User object
    
    async def change_user_password(self, tempUser: UserChangePassword):
        dbUser = await self.get_user_by_username(tempUser.username)
        if dbUser is None:
            raise HTTPException(status_code=404, detail="User not found")
        if not verify_password(tempUser.password, dbUser['password']):
            raise HTTPException(status_code=400, detail="Incorrect password")
        hashed_password = hash_password(tempUser.new_password)
        result = await self.db.users.update_one({"username": tempUser.username}, {"$set": {"password": hashed_password}})
        if result.modified_count == 0:
            raise HTTPException(status_code=400, detail="Password change failed")
        return {"message": "Password changed successfully"}
     


    