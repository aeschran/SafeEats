from fastapi import APIRouter
from services.collection_service import CollectionService
from schemas.collection import CollectionCreate, CollectionResponse, CollectionAdd

router = APIRouter(tags=["Collections"])

collection_service = CollectionService()

@router.post("")
async def create_collection_endpoint(collection: CollectionCreate):
    print("Creating collection")
    return await collection_service.create_collection(collection)

@router.get("/{user_id}")
async def get_collections_endpoint(user_id: str):
    return await collection_service.get_collections(user_id)

@router.post("/add")
async def add_business_to_collection_endpoint(collection: CollectionAdd):
    """
    Endpoint to add a business to an existing collection
    """
    print("here?")
    return await collection_service.add_business_to_collection(collection)
