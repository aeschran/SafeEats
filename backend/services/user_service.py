# app/services/user_service.py
import bcrypt
from models.user import User
from schemas.user import UserResponse, UserCreate
from db.init_db import db

def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    # Verify the password
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

class UserService:
    def __init__(self):
        self.db = db # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_new_user(self, user_create: UserCreate):
        # Create a new user in the database
        user = User(name=user_create.name, email=user_create.email, password=hash_password(user_create.password))
        result = await self.db.users.insert_one(user.to_dict())
        return {**user.to_dict(), "id": str(result.inserted_id)}

    async def get_user_by_email(self, email: str):
        # Fetch a user from the database by user_id
        user_data = await self.db.users.find_one({"email": email})
        user = UserResponse(**user_data)
        if user:
            return user
        return None

    async def get_users(self):
        # Fetch all users from the database
        users = await self.db.users.find().to_list(100)
        users = [UserResponse(**user) for user in users]
        return users