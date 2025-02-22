from models.notification import Notification
from schemas.notification import NotificationCreate, NotificationResponse
from services.base_service import BaseService
import logging
from bson import ObjectId

class NotificationService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        
    async def create_new_notification(self, notification_create: NotificationCreate):
        notification = Notification(sender_id=ObjectId(notification_create.sender_id), recipient_id=ObjectId(notification_create.recipient_id), type=notification_create.type, content=notification_create.content, timestamp=notification_create.timestamp)
        result = await self.db.notifications.insert_one(notification.to_dict())
        if result.inserted_id:
            return NotificationResponse(**notification.to_dict())
        return None
    
    async def get_notifications(self, recipient_id: str):
        recipient_id = ObjectId(recipient_id)
        pipeline = [
        {"$match": {"recipient_id": recipient_id}},  # Filter by recipient ID
        {
            "$lookup": {
                "from": "users",  # Users collection
                "localField": "sender_id",  # Field in notifications
                "foreignField": "_id",  # Matching field in users
                "as": "sender"
            }
        },
        {"$unwind": "$sender"}  # Convert sender array to an object
        ]
        notifications = await self.db.notifications.aggregate(pipeline).to_list(100)
        notifications = [NotificationResponse(**notification) for notification in notifications]
        return notifications