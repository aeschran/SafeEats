from motor.motor_asyncio import AsyncIOMotorClient
from core.config import settings

client: AsyncIOMotorClient | None = None  # Explicitly define as None initially

def connect_db():
    """Initialize the database connection."""
    global client
    if client is None:
        client = AsyncIOMotorClient(settings.MONGODB_URI)
    return client[settings.MONGO_DB_NAME] if client else None

async def close_db():
    """Close the database connection properly."""
    global client
    if client:
        client.close()
        client = None  # Reset client to None