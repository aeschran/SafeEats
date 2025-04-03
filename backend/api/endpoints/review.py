from fastapi import APIRouter, Depends, HTTPException
from services.review_service import ReviewService
from services.notification_service import NotificationService
from services.friend_service import FriendService
from schemas.notification import NotificationCreate, NotificationResponse
from schemas.friend import FriendCreate, FriendResponse
from schemas.review import ReviewCreate, ReviewAddVote, ReviewImage


router = APIRouter(tags=["Review"])


review_service = ReviewService()


@router.post("/addimage")
async def add_image(image: ReviewImage):
    review = await review_service.add_image(image)
    if not review:
        raise HTTPException(status_code=500, detail="Failed to create review")
    
    return review


@router.post("/create")
async def create_review(review_create: ReviewCreate):
    review = await review_service.create_review(review_create)
    if not review:
        raise HTTPException(status_code=500, detail="Failed to create review")
    return {"review_id" : review}


@router.get("/feed/{user_id}")
async def get_feed(user_id: str):
    reviews = await review_service.get_friends_reviews(user_id)
    # if not review:
    #     raise HTTPException(status_code=500, detail="Failed to get review")
    return reviews

@router.get("/personal_feed/{user_id}")
async def get_personal_feed(user_id: str):
    reviews = await review_service.get_own_reviews(user_id)
    return reviews

@router.get("/business/{business_id}/{user_id}")
async def get_business_reviews(business_id: str, user_id: str):
    reviews = await review_service.get_business_reviews(business_id, user_id)

    return reviews

@router.post("/vote")
async def review_vote(review_vote: ReviewAddVote):
    review = await review_service.review_vote(review_vote)
    print(review)
    if not review:
        raise HTTPException(status_code=500, detail="Failed to create review")
    return review

@router.delete("/delete/{review_id}")
async def delete_review(review_id: str):
    deleted = await review_service.delete_review(review_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Review not found or could not be deleted")
    return {"message": "Review deleted successfully"}

@router.put("/edit/{review_id}")
async def edit_review(review_id: str, review_update: ReviewCreate):
    updated_review = await review_service.edit_review(review_id, review_update)
    if not updated_review:
        raise HTTPException(status_code=404, detail="Review not found or could not be updated")
    return {"message": "Review updated successfully", "review": updated_review}


