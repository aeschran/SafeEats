# app/services/business_owner_service.py
import bcrypt
from bson import ObjectId
from datetime import datetime, timedelta
from core.config import settings
from models.business_owner import BusinessOwner
import random
import string
from schemas.business_owner import BusinessOwnerResponse, BusinessOwnerCreate
from schemas.business import BusinessResponse, BusinessCreate
from services.base_service import BaseService
import sendgrid
from sendgrid.helpers.mail import Mail, Email, To, Content
from twilio.rest import Client
from typing import List

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

        return {"success": True, "message": "Verification code sent via phone call."}
    
    async def verify_phone_code(self, owner_id: str, business_id:str, code: str):
        record = await self.db.phone_verifications.find_one({"owner_id": ObjectId(owner_id)})
        if not record or record["code"] != code:
            raise HTTPException(status_code=400, detail="Invalid verification code")

        if datetime.utcnow() > record["expires_at"]:
            raise HTTPException(status_code=400, detail="Verification code expired")

        result = await self.db.business_owners.update_one(
            {"_id": ObjectId(owner_id)}, 
            {"$set": {"isVerified": True}}
        )

        business_update = await self.db.businesses.update_one(
            {"_id": ObjectId(business_id)}, 
            {"$set": {"owner_id": owner_id}}
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

    async def get_business_listing_search(self, query: str = "") -> List[BusinessResponse]:
        try:
            print(query + "HI")
            if query.strip() == "":
                search_results_cursor = self.db.businesses.find(
                    {
                        "$and": [
                            {"owner_id": "None"}  # Only return businesses where owner_id is None
                        ]
                    },
                    # {"_id": 1, "name": 1, "address": 1, "website": 1}  # Return only relevant fields
                )  # Limit to 10 results
            else:
                search_results_cursor = self.db.businesses.find(
                    {
                        "$and": [
                            {"name": {"$regex": query, "$options": "i"}},  # Case-insensitive name search
                            {"owner_id": "None"}  # Only return businesses where owner_id is None
                        ]
                    },
                    # {"_id": 1, "name": 1, "address": 1, "website": 1}  # Return only relevant fields
                )  # Limit to 10 results
            search_results = await search_results_cursor.to_list(length=10)

            businesses = [BusinessResponse(**{**business, "id": str(business["_id"])}) for business in search_results]

            return businesses
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def get_owner_listings(self, id: str):
        try:
            print(id)
            search_results_cursor = self.db.businesses.find(
                {"owner_id": id}
            ) 
            search_results = await search_results_cursor.to_list(length=10)

            businesses = [BusinessResponse(**{**business, "id": str(business["_id"])}) for business in search_results]
            return businesses
        
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def create_owner_listing(self, business_create):
        try:
            new_business = BusinessCreate (
                name=business_create.name,
                owner_id=business_create.owner_id,
                website=business_create.website,
                tel=business_create.tel,
                description=business_create.description,
                cuisines=business_create.cuisines,
                menu=business_create.menu,
                address=business_create.address,
                location=business_create.location,
                dietary_restrictions=business_create.dietary_restrictions
            )
            result = await self.db.business.insert_one(new_business.to_dict())
            if result.inserted_id:
                return 1
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))