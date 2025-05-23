from http.client import HTTPException
from models.notification import Notification
from schemas.notification import NotificationCreate, NotificationResponse, CreateNotificationResponse
from utils.enums import NotificationEnum
from services.base_service import BaseService
from services.user_service import UserService
import logging
from bson import ObjectId

class NotificationService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        
    async def create_new_notification(self, notification_create: NotificationCreate):
        try: 
            sender_id = ObjectId(notification_create.sender_id)
            recipient_id = ObjectId(notification_create.recipient_id)

            # No assumptions about recipient being a user.
            notification = Notification(
                sender_id=sender_id,
                recipient_id=recipient_id,
                type=notification_create.type,
                content=notification_create.content,
                timestamp=notification_create.timestamp
            )

            result = await self.db.notifications.insert_one(notification.to_dict())
            if result.inserted_id:
                # Only try to fetch sender username IF type == friend request
                sender_username = None
                if notification_create.type == NotificationEnum.FRIEND_REQUEST:
                    sender_user = await self.db.users.find_one({"_id": sender_id})
                    sender_username = sender_user.get("name") if sender_user else None

                return CreateNotificationResponse(
                    sender_id=str(sender_id),
                    recipient_id=str(recipient_id),
                    type=notification.type.value,
                    content=notification.content,
                    timestamp=notification.timestamp,
                    sender_username=sender_username
                )
            return None
        except Exception as e:
            print(f"Error creating notification: {e}")
            raise HTTPException(status_code=500, detail="Internal Server Error")

    
    async def create_new_friend_request(self, notification_create: NotificationCreate):
        notification_create = NotificationCreate(sender_id=ObjectId(notification_create.sender_id), recipient_id=ObjectId(notification_create.recipient_id), type=notification_create.type, content=notification_create.content, timestamp=notification_create.timestamp)
        result = await self.db.friends.find_one({"user_id": ObjectId(notification_create.sender_id), "friend_id": ObjectId(notification_create.recipient_id)})
        if result:
            return None
        result = await self.db.friends.find_one({"user_id": ObjectId(notification_create.recipient_id), "friend_id": ObjectId(notification_create.sender_id)})
        if result:
            return None
        return await self.create_new_notification(notification_create)
    
    async def create_new_report(self, notification_create: NotificationCreate):
        reported_user_cursor = await self.db.users.find_one({"_id": ObjectId(notification_create.sender_id)})
        if reported_user_cursor:
            reported_user = reported_user_cursor["name"]
        else:
            return None
        report_content = "You reported " + str(reported_user) + " for: " + notification_create.content
        notification_create_report = NotificationCreate(sender_id=str(notification_create.sender_id), recipient_id=str(notification_create.recipient_id), type=notification_create.type, content=notification_create.content, timestamp=notification_create.timestamp)
        user_service = UserService()
        await user_service.report_user(str(notification_create.recipient_id), str(notification_create.sender_id), notification_create.content, notification_create.timestamp)
        return await self.create_new_notification(notification_create)
    
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
            {"$unwind": "$sender"},  # Convert sender array to an object
            {
                "$project": {
                    "notification_id": "$_id",  # Create a new field 'notification_id' with the value of '_id'
                    "recipient_id": 1,
                    "sender_id": "$sender._id",  # Flatten sender_id
                    "sender_username": "$sender.username",  # Add sender_username field
                    "type": 1,
                    "content": 1,
                    "timestamp": 1
                    }
                }
            ]
        notifications = await self.db.notifications.aggregate(pipeline).to_list()
        notifications = [NotificationResponse(**notification) for notification in notifications]
        return notifications
    
    # async def delete_notification(self, _id: str) -> bool:
    #     result = await self.db.notifications.delete_one({"_id": ObjectId(_id)})
    #     return result.deleted_count == 1
    
    async def delete_notification(self, notification_id: str) -> bool:
        result = await self.db.notifications.delete_one({"_id": ObjectId(notification_id)})
        # if result.deleted_count != 1:
        #     result = await self.db.notifications.delete_one({"recipient_id": ObjectId(sender_id), "sender_id": ObjectId(recipient_id)})
        return result.deleted_count == 1
    
    async def delete_all_notifications(self, recipient_id: str) -> bool:
        recipient_id = ObjectId(recipient_id)
        result = await self.db.notifications.delete_many({"recipient_id": recipient_id})
        return result.deleted_count > 0
