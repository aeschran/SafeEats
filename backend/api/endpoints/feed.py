from fastapi import APIRouter, Depends, HTTPException
from services.notification_service import NotificationService
from services.friend_service import FriendService
from schemas.notification import NotificationCreate, NotificationResponse
from schemas.friend import FriendCreate, FriendResponse

router = APIRouter(tags=["Friends"])

friend_service = FriendService()
notification_service = NotificationService()


@router.get("/")
async def get_user_feed(user_id: str):
    friends = await friend_service.get_friends(user_id)
    return friends

async def create_friend(friend_create: FriendCreate):
    notification = await notification_service.delete_notification(friend_create.notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Failed to create friend 1")
    friend = await friend_service.create_new_friend(friend_create)
    if not friend:
        raise HTTPException(status_code=400, detail="Failed to create friend 2")
    return friend

