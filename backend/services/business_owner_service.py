# app/services/business_owner_service.py
import bcrypt
from bson import ObjectId
from datetime import datetime, timedelta
from core.config import settings
from models.business_owner import BusinessOwner
import random
import string
from schemas.business_owner import BusinessOwnerResponse, BusinessOwnerCreate
from services.base_service import BaseService
import sendgrid
from sendgrid.helpers.mail import Mail, Email, To, Content
from twilio.rest import Client

from fastapi import Depends, HTTPException, status
from services.jwttoken import verify_token, create_access_token
from fastapi.security import OAuth2PasswordBearer
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def generate_verification_code():
    return "".join(random.choices(string.digits, k=6))



def send_verification_email(email: str, code: str):
    sg = sendgrid.SendGridAPIClient(api_key=settings.SENDGRID_KEY)
    from_email = Email("safeeats.noreply@gmail.com")
    to_email = To(email)
    subject = "SafeEats Business Password Reset Code"
    content = Content("text/plain", f"Your SafeEats verification code is: {code}\n\nThis code expires in 10 minutes.")
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
        business_owner = BusinessOwner(name=business_owner_create.name, email=business_owner_create.email, password=hash_password(business_owner_create.password), phone=business_owner_create.phone, isVerified=business_owner_create.isVerified)
        result = await self.db.business_owners.insert_one(business_owner.to_dict())

        token = create_access_token({"email": business_owner.email, "id": str(result.inserted_id)})

        return {
            **business_owner.to_dict(),
            "id": str(result.inserted_id),
            "access_token": token,  
            "token_type": "bearer"
        }
    
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
    
    

    async def verify_business_owner(self, owner_id: str, business_phone: str):
        verification_code = generate_verification_code()
        expiration_time = datetime.utcnow() + timedelta(minutes=10)

        # Store the verification code in Mongo
        await self.db.phone_verifications.update_one(
            {"owner_id": ObjectId(owner_id)},
            {"$set": {"code": verification_code, "expires_at": expiration_time}},
            upsert=True
        )

        # Initiate Twilio phone call
        client = Client(settings.TWILIO_SID, settings.TWILIO_AUTH_TOKEN)
        formatted_code = " ".join(list(verification_code))
        twiml = f"""
        <Response>
            <Say> Your Safe Eats verification code is </Say>
            <Say>
                <prosody rate="x-slow">{formatted_code}</prosody>
            </Say>
            <Say> Repeat. Your Safe Eats verification code is </Say>
            <Say>
                <prosody rate="x-slow">{formatted_code}</prosody>
            Goodbye.
            </Say>
        </Response>
        """

        try:
            client.calls.create(
                to=business_phone,
                from_=settings.TWILIO_PHONE,
                twiml=twiml
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to send verification call: {str(e)}")

        return {"message": "Verification code sent via phone call."}
    
    async def verify_phone_code(self, owner_id: str, code: str):
        record = await self.db.phone_verifications.find_one({"owner_id": ObjectId(owner_id)})
        if not record or record["code"] != code:
            raise HTTPException(status_code=400, detail="Invalid verification code")

        if datetime.utcnow() > record["expires_at"]:
            raise HTTPException(status_code=400, detail="Verification code expired")

        result = await self.db.business_owners.update_one(
            {"_id": ObjectId(owner_id)}, 
            {"$set": {"isVerified": True}}
        )

        # clean up
        await self.db.phone_verifications.delete_one({"owner_id": ObjectId(owner_id)})

        return {"message": "Business owner verified successfully."}
    
    async def forgot_password(self, email: str):
        business_owner = await self.get_business_owner_by_email(email)
        if not business_owner:
            raise HTTPException(status_code=400, detail="Business owner not found")
        verification_code = generate_verification_code()
        expiration_time = datetime.utcnow() + timedelta(minutes=10)

        # storing verification code in DB
        await self.db.password_resets.update_one(
            {"email": email},
            {"$set": {"code": verification_code, "expires_at": expiration_time}},
            upsert=True
        )

        send_verification_email(email, verification_code)
        return {"message": "Verification code sent."}
    
    async def verify_code(self, email: str, code: str):
        record = await self.db.password_resets.find_one({"email": email})
        if not record or record["code"] != code:
            raise HTTPException(status_code=400, detail="Invalid verification code")

        if datetime.utcnow() > record["expires_at"]:
            raise HTTPException(status_code=400, detail="Verification code expired")

        return {"message": "Code verified. You can now reset your password."}
    
   
    async def reset_password(self, email: str, code: str, new_password: str):
        record = await self.db.password_resets.find_one({"email": email})
        if not record or record["code"] != code:
            raise HTTPException(status_code=400, detail="Invalid or expired verification code")
        
        hashed_password = hash_password(new_password)

        # Update password 
        result = await self.db.business_owners.update_one(
            {"email": email}, {"$set": {"password": hashed_password}}
        )
        await self.db.password_resets.delete_one({"email": email})

        return {"message": "Password reset successful"}
