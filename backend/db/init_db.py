from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from core.config import settings

client: AsyncIOMotorClient = AsyncIOMotorClient(settings.MONGODB_URI)
db: AsyncIOMotorDatabase = client[settings.MONGODB_NAME]

async def connect_db():
    """Initialize the database connection and remove unwanted businesses."""
    global client, db
    if client is None:
        client = AsyncIOMotorClient(settings.MONGODB_URI)
        db = client[settings.MONGODB_NAME]
        assert db is not None, "DB initialization failed."

    # Find and remove duplicate businesses based on name & address
    pipeline = [
        {
            "$group": {
                "_id": {"name": "$name", "address": "$address"},
                "uniqueIds": {"$addToSet": "$_id"},
                "count": {"$sum": 1}
            }
        },
        {
            "$match": {"count": {"$gt": 1}}
        }
    ]

    duplicates = await db.businesses.aggregate(pipeline).to_list(length=None)

    for doc in duplicates:
        unique_ids = doc["uniqueIds"]
        unique_ids.pop(0)  # Keep one document, remove the rest
        if unique_ids:
            await db.businesses.delete_many({"_id": {"$in": unique_ids}})

    # Delete businesses that do not have at least one cuisine in the range [13000, 14000]
    # await db.businesses.delete_many({
    #     "cuisines": {
    #         "$not": {"$elemMatch": {"$gte": 13000, "$lte": 14000}}
    #     }
    # })

    # Ensure uniqueness of businesses based on name & address
    await db.businesses.create_index(
        [("name", 1), ("address", 1)],
        unique=True
    )

    return db

async def close_db():
    """Close the database connection properly."""
    global client, db
    if client:
        client.close()
        client = None  # Reset client to None
        db = None  # Reset db to None