# app/services/business_owner_service.py
import bcrypt
from bson import ObjectId
from core.config import settings
from models.business_owner import BusinessOwner
from schemas.business_owner import BusinessOwnerResponse, BusinessOwnerCreate
from services.base_service import BaseService
import sendgrid
from sendgrid.helpers.mail import Mail, Email, To, Content


from fastapi import Depends, HTTPException, status
from services.jwttoken import verify_token, verify_reset_token, create_reset_token
from fastapi.security import OAuth2PasswordBearer
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))



def send_reset_email(email: str, token: str):
    sg = sendgrid.SendGridAPIClient(api_key=settings.SENDGRID_KEY)
    from_email = Email("safeeats.noreply@gmail.com")
    to_email = To(email)
    subject = "SafeEats Password Reset Request"
    content = Content("text/plain", f"Hi there!\n\nClick the link to reset your business account password:\n https://your-app.com/reset-password?token={token}\n\nThis link will expire in 1 hour.")
    mail = Mail(from_email, to_email, subject, content)
    
    response = sg.send(mail)
    print(response.status_code, response.body, response.headers)




class BusinessOwnerService(BaseService):
    def __init__(self):
        super().__init__() # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_new_business_owner(self, business_owner_create: BusinessOwnerCreate):
        # Create a new business owner in the database
        # Default not validated as a business owner
        existing_owner = await self.db.business_owners.find_one({"email": business_owner_create.email})
        if existing_owner:
            raise HTTPException(
                status_code=400,
                detail="Email already registered."
            )
        business_owner = BusinessOwner(name=business_owner_create.name, email=business_owner_create.email, password=hash_password(business_owner_create.password), isVerified=business_owner_create.isVerified)
        result = await self.db.business_owners.insert_one(business_owner.to_dict())
        return {**business_owner.to_dict(), "id": str(result.inserted_id)}
    
    async def delete_business_owner(self, _id: str) -> bool:
        # Delete a owner from database by email
        
        result = await self.db.business_owners.delete_one({"_id": ObjectId(_id)})
        return result.deleted_count == 1

    async def get_business_owner_by_email(self, email: str):
        # Fetch a business owner from the database by business owner
        business_owner = await self.db.business_owners.find_one({"email": email})
        #business_owner = BusinessOwnerResponse(**business_owner_data)
        if business_owner:
            return business_owner
        return None

    async def get_business_owners(self):
        # Fetch all business owner from the database
        business_owners = await self.db.business_owners.find().to_list(100)
        business_owners = [BusinessOwnerResponse(**business_owner) for business_owner in business_owners]
        return business_owners
    
    async def verify_business_owner(self, owner_id: str):
        # Mark a business owner as verified
        result = await self.db.business_owners.update_one(
            {"_id": ObjectId(owner_id)}, 
            {"$set": {"isVerified": True}}
        )
        return result.modified_count > 0  # Returns True if an update was made
    
    async def forgot_password(self, email: str):
        business_owner = await self.get_business_owner_by_email(email)
        if not business_owner:
            raise HTTPException(status_code=400, detail="Business owner not found")

        reset_token = create_reset_token(data={"sub": email})
        
        send_reset_email(email, reset_token)
        return {"message": "Password reset link sent."}
    
   
    async def reset_password(self, token: str, new_password: str):
        email = verify_reset_token(token, credentials_exception=HTTPException(status_code=401, detail="Invalid or expired token"))
        
        business_owner = await self.get_business_owner_by_email(email)
        if not business_owner:
            raise HTTPException(status_code=404, detail="Business owner not found")

        hashed_password = hash_password(new_password)

        # Update password in the database
        result = await self.db.business_owners.update_one(
            {"email": email}, {"$set": {"password": hashed_password}}
        )

        return result.modified_count > 0 
