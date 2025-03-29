from fastapi import APIRouter, Depends, HTTPException
from services.review_service import ReviewService
from services.notification_service import NotificationService
from services.friend_service import FriendService
from schemas.notification import NotificationCreate, NotificationResponse
from schemas.friend import FriendCreate, FriendResponse
from schemas.review import ReviewCreate


router = APIRouter(tags=["Review"])


review_service = ReviewService()


@router.post("/create")
async def create_review(review_create: ReviewCreate):
    review = await review_service.create_review(review_create)
    if not review:
        raise HTTPException(status_code=500, detail="Failed to create review")
    return review