from fastapi import APIRouter
from services.collections_service import CollectionsService

router = APIRouter(tags=["Collections"])

collections_service = CollectionsService()