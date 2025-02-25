from fastapi import APIRouter, Depends, HTTPException
from services.notification_service import NotificationService
from services.friend_service import FriendService
from schemas.notification import NotificationCreate, NotificationResponse
from schemas.friend import FriendCreate, FriendResponse

router = APIRouter(tags=["Friends"])

friend_service = FriendService()
notification_service = NotificationService()

@router.get("/{user_id}")
async def get_friends(user_id: str):
    friends = await friend_service.get_friends(user_id)
    return friends

@router.post("/create")
async def create_friend_request(friend_create: NotificationCreate):
    notification = await notification_service.create_new_friend_request(friend_create)
    if not notification:
        raise HTTPException(status_code=500, detail="Failed to create friend request")
    return notification

@router.post("/accept")
async def create_friend(friend_create: FriendCreate):
    notification = await notification_service.delete_notification(friend_create.user_id, friend_create.friend_id)
    if not notification:
        raise HTTPException(status_code=500, detail="Failed to create friend")
    friend = await friend_service.create_new_friend(friend_create)
    if not friend:
        raise HTTPException(status_code=500, detail="Failed to create friend")
    return friend
    
@router.post("/deny")
async def deny_friend(friend_create: FriendCreate):
    notification = await notification_service.delete_notification(friend_create.user_id, friend_create.friend_id)
    if not notification:
        raise HTTPException(status_code=500, detail="Failed to deny friend")
    return notification
