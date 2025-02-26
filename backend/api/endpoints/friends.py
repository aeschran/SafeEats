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
    notification = await notification_service.delete_notification(friend_create.notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Failed to create friend 1")
    friend = await friend_service.create_new_friend(friend_create)
    if not friend:
        raise HTTPException(status_code=400, detail="Failed to create friend 2")
    return friend
    
@router.post("/deny")
async def deny_friend(friend_create: FriendCreate):
    notification = await notification_service.delete_notification(friend_create.notification_id)
    if not notification:
        raise HTTPException(status_code=500, detail="Failed to deny friend")
    return notification

@router.delete("/unfollow")
async def unfollow_friend(friend_create: FriendCreate):
    success = await friend_service.unfollow_friend(friend_create.user_id, friend_create.friend_id)

    if not success:
            raise HTTPException(status_code=500, detail="Failed to unfollow friend")
    return {"message": "Friend removed successfully"}

