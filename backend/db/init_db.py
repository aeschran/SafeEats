from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from core.config import settings

client: AsyncIOMotorClient = AsyncIOMotorClient(settings.MONGODB_URI)
db: AsyncIOMotorDatabase = client[settings.MONGODB_NAME]

async def connect_db():
    """Initialize the database connection."""
    global client, db
    if client is None:
        client = AsyncIOMotorClient(settings.MONGODB_URI)
        db = client[settings.MONGODB_NAME]
        assert db is not None, "DB initialization failed."
    return db

async def close_db():
    """Close the database connection properly."""
    global client, db
    if client:
        client.close()
        client = None  # Reset client to None
        db = None  # Reset db to None