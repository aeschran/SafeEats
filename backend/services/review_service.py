from models.review import Review
from schemas.review import ReviewCreate, ReviewResponse
from services.base_service import BaseService
import logging
from bson import ObjectId
from fastapi import HTTPException
import time

class ReviewService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        
    async def create_review(self, review_create: ReviewCreate):
        try :
            review_image = review_create.review_image if review_create.review_image else None  # Ensure it's None if empty
            review = Review(
                user_id=ObjectId(review_create.user_id),
                business_id=ObjectId(review_create.business_id),
                review_content=review_create.review_content,
                rating=review_create.rating,
                review_image=review_image
            )
            result = await self.db.user_reviews.insert_one(review.to_dict())

            if result.inserted_id:
                return 1  # Success
            return None

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    # async def get_friends_reviews(self, user_id: str):
        # get list of friends id
        # iterate throuhgh list of friends
        # return list of reviews with the friend's id and name and the business id and name. 
        # [
        #     {
        #         user_id: str  // this is the id of the user who made the review
        #         review_id: str
        #         business_id: str
        #         user_name: str // this is the name of the user who made the review 
        #         business_name: str
        #         review_content: str
        #         rating: int
        #         review_image: str
        #     }

        # ]

