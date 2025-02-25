from fastapi import APIRouter, Depends, HTTPException
from services.preference_service import PreferenceService
from schemas.preference import PreferenceCreate, PreferenceResponse


router = APIRouter(tags=["Preferences"])

preference_service = PreferenceService()

@router.get("")
async def get_preferences():
    preferences = await preference_service.get_preferences()
    return preferences

@router.post("")
async def create_preference(preference: PreferenceCreate):
    return await preference_service.create_new_preference(preference)