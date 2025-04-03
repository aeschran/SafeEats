from fastapi import APIRouter
from services.collection_service import CollectionService
from schemas.collection import CollectionCreate, CollectionResponse, CollectionAdd, CollectionEdit, CollectionRemoveBusiness

router = APIRouter(tags=["Collections"])

collection_service = CollectionService()

@router.post("")
async def create_collection_endpoint(collection: CollectionCreate):
    """
    Endpoint to create a new collection
    """
    return await collection_service.create_collection(collection)

@router.get("/{user_id}")
async def get_collections_endpoint(user_id: str):
    """
    Endpoint to get all collections for a user
    """
    return await collection_service.get_collections(user_id)

@router.post("/add")
async def add_business_to_collection_endpoint(collection: CollectionAdd):
    """
    Endpoint to add a business to an existing collection
    """
    return await collection_service.add_business_to_collection(collection)

@router.post("/edit")
async def edit_collection_endpoint(collection: CollectionEdit):
    """
    Endpoint to edit a collection
    """
    # Note: This endpoint is for editing the collection name only, not the businesses inside it.
    return await collection_service.edit_collection(collection=collection)

@router.post("/remove-business")
async def remove_business_from_collection_endpoint(collection: CollectionRemoveBusiness):
    """
    Endpoint to remove a business from a collection
    """
    result = await collection_service.remove_business_from_collection(collection)
    if result is None:
        return {"error": "Failed to remove business from collection"}
    
    return result