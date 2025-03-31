from models.review import Review, ReviewVote
from schemas.review import ReviewCreate, ReviewResponse, ReviewAddVote
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
                review_image=review_image,
                upvotes=0,
                downvotes=0
            )
            result = await self.db.user_reviews.insert_one(review.to_dict())

            if result.inserted_id:
                return 1  # Success
            return None

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def get_friends_reviews(self, user_id: str):
        try:
            user_object_id = ObjectId(user_id)

            # Step 1: Find All Friends (Search in both user_id and friend_id fields)
            friends_cursor = self.db.friends.find(
                {"$or": [{"user_id": user_object_id}, {"friend_id": user_object_id}]}
            )
            print(friends_cursor)

            friends = await friends_cursor.to_list(None)
            print(friends)

            
            # Extract friend IDs
            friend_ids = set()
            for friend in friends:
                if friend["user_id"] == user_object_id:
                    friend_ids.add(friend["friend_id"])
                else:
                    friend_ids.add(friend["user_id"])

            if not friend_ids:
                return []  # Return empty list if user has no friends

            # Step 2: Find Reviews by Friends
            reviews_cursor = self.db.user_reviews.find(
                {"user_id": {"$in": list(friend_ids)}}
            ).sort("review_timestamp", -1)  # Sort by most recent

            reviews = await reviews_cursor.to_list(None)

            # Step 3: Get User Names
            friend_ids_list = list(friend_ids)
            users_cursor = self.db.users.find({"_id": {"$in": friend_ids_list}})
            users = {str(user["_id"]): user["name"] for user in await users_cursor.to_list(None)}


            # Step 4: Get Business Names
            business_ids = {ObjectId(review["business_id"]) for review in reviews if review.get("business_id")}
            print("Business IDs being queried:", business_ids)  # Debugging step

            # Query MongoDB for business names
            businesses_cursor = self.db.businesses.find({"_id": {"$in": list(business_ids)}})
            businesses = {str(business["_id"]): business["name"] for business in await businesses_cursor.to_list(None)}

            print("Fetched Businesses:", businesses)  # Debugging step

            # Step 5: Format the Response
            result = []
            for review in reviews:
                result.append({
                    "review_id": str(review["_id"]),
                    "user_id": str(review["user_id"]),
                    "business_id": str(review["business_id"]),
                    "user_name": users.get(str(review["user_id"]), "Unknown"),
                    "business_name": businesses.get(str(review["business_id"]), "Unknown"),
                    "review_content": review["review_content"],
                    "rating": review["rating"],
                    "review_image": review.get("review_image", None),  # Handle missing field
                    "review_timestamp": review["review_timestamp"],
                })

            return result if result else [] 
        
        except Exception as e:
            return []

    async def get_business_reviews(self, business_id: str, user_id: str):
        try:
            reviews_cursor = self.db.user_reviews.find({"business_id": ObjectId(business_id)})
            
            reviews = await reviews_cursor.to_list(None)
            print(reviews) 
            result = []
            
            for review in reviews:
                user_doc = await self.db.users.find_one({"_id": review["user_id"]})
                user_name = user_doc["name"] if user_doc else "Unknown"
                print(user_name)
                print(review["_id"])
                print(user_id)
                user_vote_cursor = await self.db.review_votes.find_one({"review_id": review["_id"], "user_id": ObjectId(user_id)})
                if user_vote_cursor:
                    if user_vote_cursor["vote"] == 0:
                        result.append({
                            "review_id": str(review["_id"]),
                            "user_id": str(review["user_id"]),
                            "business_id": str(review["business_id"]),
                            "user_name": user_name,
                            "review_content": review["review_content"],
                            "rating": review["rating"],
                            "review_timestamp": review["review_timestamp"],
                            "upvotes": review["upvotes"],
                            "downvotes": review["downvotes"],
                            "user_vote": -1
                        })
                    #downvote
                    elif user_vote_cursor["vote"] == 1:
                        result.append({
                            "review_id": str(review["_id"]),
                            "user_id": str(review["user_id"]),
                            "business_id": str(review["business_id"]),
                            "user_name": user_name,
                            "review_content": review["review_content"],
                            "rating": review["rating"],
                            "review_timestamp": review["review_timestamp"],
                            "upvotes": review["upvotes"],
                            "downvotes": review["downvotes"],
                            "user_vote": 1
                        })
                else:
                    #upvote
                    result.append({
                        "review_id": str(review["_id"]),
                        "user_id": str(review["user_id"]),
                        "business_id": str(review["business_id"]),
                        "user_name": user_name,
                        "review_content": review["review_content"],
                        "rating": review["rating"],
                        "review_timestamp": review["review_timestamp"],
                        "upvotes": review["upvotes"],
                        "downvotes": review["downvotes"],
                    })
            return result

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    async def review_vote(self, review_vote: ReviewVote):
        try :
            vote = ReviewVote(
                    user_id=ObjectId(review_vote.user_id),
                    review_id=ObjectId(review_vote.review_id),
                    vote=review_vote.vote,
                )
            if vote.vote < 2:
                print(vote)
                result = await self.db.review_votes.insert_one(vote.to_dict())
                if vote.vote == 0:
                    update = await self.db.user_reviews.find_one_and_update({
                        "_id": vote.review_id},
                        {"$inc": {"downvotes" : 1}},
                        )
                else :
                    update = await self.db.user_reviews.find_one_and_update({
                        "_id": vote.review_id},
                        {"$inc": {"upvotes" : 1}},
                        )

            else:
                result = await self.db.review_votes.delete_one({
                    "user_id": vote.user_id,
                    "review_id": vote.review_id
                })
                if vote.vote == 2:
                    update = await self.db.user_reviews.find_one_and_update({
                            "_id": vote.review_id},
                            {"$inc": {"downvotes" : -1}}
                    )
                else:
                    update = await self.db.user_reviews.find_one_and_update({
                            "_id": vote.review_id},
                            {"$inc": {"upvotes" : -1}}
                    )


            if result:
                return 1  # Success
            return None

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))