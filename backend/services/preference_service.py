from models.preference import Preference
from schemas.preference import PreferenceCreate, PreferenceResponse
from services.base_service import BaseService
from sendgrid.helpers.mail import Mail, Email, To, Content
from core.config import settings
import sendgrid
from fastapi import HTTPException

def send_suggestion_email(new_prefs: list[str]):
    if len(new_prefs) == 0:
        raise HTTPException(status_code=400, detail="No new preferences to suggest")
    if len(new_prefs) == 1:
        string = "New preference suggestion:"
    else:
        string = "New preference suggestions:"
    sg = sendgrid.SendGridAPIClient(api_key=settings.SENDGRID_KEY)
    from_email = Email("safeeats.noreply@gmail.com")
    to_email = To("safeeats.dev@gmail.com")
    subject = "New Preference Suggestions"
    content = Content("text/plain", string + f"\n\n" + "\n".join(new_prefs))
    mail = Mail(from_email, to_email, subject, content)
    response = sg.send(mail)
    print(response.status_code, response.body, response.headers)
    return response.status_code == 202

class PreferenceService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection not available")
        
    async def create_new_preference(self, preference_create: PreferenceCreate):
        preference = Preference(preference=preference_create.preference, preference_type=preference_create.preference_type)
        result = await self.db.preferences.find_one({"preference": preference_create.preference, "preference_type": preference_create.preference_type})
        if result:
            return None
        result = await self.db.preferences.insert_one(preference.to_dict())
        if result.inserted_id:
            return PreferenceResponse(**preference.to_dict())
        return None
    
    async def get_preferences(self):
        preferences = await self.db.preferences.find().to_list(100)
        preferences = [PreferenceResponse(**preference) for preference in preferences]
        return preferences
    
    async def suggest_preferences(self, new_prefs: list[str]):
        res = send_suggestion_email(new_prefs)
        if res:
            return {"status": "success", "message": "Email sent successfully"}
        else:
            raise HTTPException(status_code=500, detail="Failed to send email")