from backend.models.collections import CollectionCreate
from backend.services.base_service import BaseService

class CollectionService(BaseService):
    def __init__(self):
        super().__init__()  # Get the database connection
        if self.db is None:
            raise Exception("Database connection failed.")
    

    async def create_new_collection(self, collection_create: CollectionCreate):
        pass