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

@router.post("/create/friend/request")
async def create_friend_request_notification(notification_create: NotificationCreate):
    notification = await notification_service.create_new_friend_request(notification_create)
    if notification:
        return notification
    raise HTTPException(status_code=500, detail="Failed to create notification")

@router.post("/create/report")
async def create_report_notification(notification_create: NotificationCreate):
    notification = await notification_service.create_new_report(notification_create)
    if notification:
        return notification
    raise HTTPException(status_code=500, detail="Failed to create notification")

@router.get("/{recipient_id}")
async def get_notifications(recipient_id: str):
    notifications = await notification_service.get_notifications(recipient_id)
    return notifications

@router.delete("/delete/{notification_id}")
async def delete_notification(notification_id: str):
    success = await notification_service.delete_notification(notification_id)
    if success:
        return {"message": "Notification deleted successfully"}
    raise HTTPException(status_code=404, detail="Notification not found")
