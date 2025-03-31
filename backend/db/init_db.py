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
    # pipeline = [
    #         {
    #             "$group": {
    #                 "_id": {"name": "$name", "address": "$address"},
    #                 "uniqueIds": {"$addToSet": "$_id"},
    #                 "count": {"$sum": 1}
    #             }
    #         },
    #         {
    #             "$match": {"count": {"$gt": 1}}
    #         }
    #     ]

    # duplicates = await db.businesses.aggregate(pipeline).to_list(length=None)

    # # Loop through duplicate groups and delete all but one
    # for doc in duplicates:
    #     unique_ids = doc["uniqueIds"]
    #     # Keep the first document, delete the others
    #     unique_ids.pop(0)

    #     if unique_ids:
    #         await db.businesses.delete_many({"_id": {"$in": unique_ids}})

    # await db.businesses.create_index(
    #     [("name", 1), ("address", 1)],
    #     unique=True
    # )
    return db

async def close_db():
    """Close the database connection properly."""
    global client, db
    if client:
        client.close()
        client = None  # Reset client to None
        db = None  # Reset db to None