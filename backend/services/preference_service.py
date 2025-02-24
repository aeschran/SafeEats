from models.preference import Preference
from schemas.preference import PreferenceCreate, PreferenceResponse
from services.base_service import BaseService

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