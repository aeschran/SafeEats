from fastapi import APIRouter, Depends, HTTPException
from services.notification_service import NotificationService
from schemas.notification import NotificationCreate, NotificationResponse

router = APIRouter(tags=["Notifications"])

notification_service = NotificationService()

@router.post("/create")
async def create_notification(notification_create: NotificationCreate):
    notification = await notification_service.create_new_notification(notification_create)
    if notification:
        return notification
    raise HTTPException(status_code=500, detail="Failed to create notification")

@router.get("/{recipient_id}")
async def get_notifications(recipient_id: str):
    notifications = await notification_service.get_notifications(recipient_id)
    return notifications
