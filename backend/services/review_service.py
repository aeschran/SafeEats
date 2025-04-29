from models.review import Review, ReviewVote, ReviewAddImage
from schemas.review import ReviewCreate, ReviewResponse, ReviewAddVote, ReviewImage, ReportReview
from services.base_service import BaseService
import logging
from bson import ObjectId
from fastapi import HTTPException
import time
import sendgrid
from sendgrid.helpers.mail import Mail, Email, To, Content
from core.config import settings

class ReviewService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        
    async def create_review(self, review_create: ReviewCreate):
        try :
            # review_image = review_create.review_image if review_create.review_image else None  # Ensure it's None if empty
            review = Review(
                user_id=ObjectId(review_create.user_id),
                business_id=ObjectId(review_create.business_id),
                review_content=review_create.review_content,
                rating=review_create.rating,
                # review_image=review_image,
                upvotes=0,
                downvotes=0,
                meal=review_create.meal,
                accommodations=review_create.accommodations

            )
            result = await self.db.user_reviews.insert_one(review.to_dict())

            if result.inserted_id:
                return str(result.inserted_id) # Success
            return None

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def add_image(self, image: ReviewImage):
        try :
            # review_image = review_create.review_image if review_create.review_image else None  # Ensure it's None if empty
            review_image = ReviewAddImage(
                review_id=ObjectId(image.review_id),
                review_image=image.review_image,
            )
            result = await self.db.review_images.insert_one(review_image.to_dict())

            if result.inserted_id:
                return str(result.inserted_id) # Success
            return None
    
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))


    async def update_image(self, image: ReviewImage):
        try:
            review_id = ObjectId(image.review_id)

            existing = await self.db.review_images.find_one({"review_id": review_id})

            if existing:
                result = await self.db.review_images.update_one(
                    {"review_id": review_id},
                    {"$set": {"review_image": image.review_image}}
                )
                return result.modified_count > 0  # True if image was updated

            else:
                review_image = ReviewAddImage(
                    review_id=review_id,
                    review_image=image.review_image,
                )
                result = await self.db.review_images.insert_one(review_image.to_dict())
                return result.inserted_id is not None

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to update image: {str(e)}")


       
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

    async def get_own_reviews(self, user_id: str):
    
        try:
            user_object_id = ObjectId(user_id)

            # Step 1: Find Reviews by the User
            reviews_cursor = self.db.user_reviews.find({"user_id": user_object_id})
            reviews = await reviews_cursor.to_list(None)
            print("User Reviews:", reviews)  # Debugging step

            if not reviews:
                return []  # Return empty list if the user has no reviews

            business_ids = {ObjectId(review["business_id"]) for review in reviews if review.get("business_id")}
            print("Business IDs being queried:", business_ids)  # Debugging step

            businesses_cursor = self.db.businesses.find({"_id": {"$in": list(business_ids)}})
            businesses = {str(business["_id"]): business["name"] for business in await businesses_cursor.to_list(None)}
            print("Fetched Businesses:", businesses)  # Debugging step

            user_cursor = await self.db.users.find_one({"_id": user_object_id})
            user_name = user_cursor["name"] if user_cursor else "Unknown"
            print("User Name:", user_name)  # Debugging step

            result = []
            for review in reviews:
                review_image_cursor = await self.db.review_images.find_one({"review_id": ObjectId(review["_id"])})
                if review_image_cursor:
                    review["review_image"] = review_image_cursor["review_image"]
                else:
                    review["review_image"] = ""
                
                result.append({
                    "review_id": str(review["_id"]),
                    "user_id": str(review["user_id"]),
                    "business_id": str(review["business_id"]),
                    "user_name": user_name,  
                    "business_name": businesses.get(str(review["business_id"]), "Unknown"),
                    "review_content": review["review_content"],
                    "rating": review["rating"],
                    "review_image": review["review_image"],  
                    "review_timestamp": review["review_timestamp"],
                    "meal": review["meal"],
                    "accommodations": review["accommodations"]
                })

            return result if result else []

        except Exception as e:
            print("Error:", str(e))  
            return []
        
    async def get_user_reviews(self, user_id: str):
    
        try:
            user_object_id = ObjectId(user_id)

            # Step 1: Find Reviews by the User
            reviews_cursor = self.db.user_reviews.find({"user_id": user_object_id})
            reviews = await reviews_cursor.to_list(None)
            print("User Reviews:", reviews)  # Debugging step

            if not reviews:
                return []  # Return empty list if the user has no reviews

            business_ids = {ObjectId(review["business_id"]) for review in reviews if review.get("business_id")}
            print("Business IDs being queried:", business_ids)  # Debugging step

            businesses_cursor = self.db.businesses.find({"_id": {"$in": list(business_ids)}})
            businesses = {str(business["_id"]): business["name"] for business in await businesses_cursor.to_list(None)}
            print("Fetched Businesses:", businesses)  # Debugging step

            user_cursor = await self.db.users.find_one({"_id": user_object_id})
            user_name = user_cursor["name"] if user_cursor else "Unknown"
            print("User Name:", user_name)  # Debugging step

            result = []
            for review in reviews:
                review_image_cursor = await self.db.review_images.find_one({"review_id": ObjectId(review["_id"])})
                if review_image_cursor:
                    review["review_image"] = review_image_cursor["review_image"]
                else:
                    review["review_image"] = ""
                
                result.append({
                    "review_id": str(review["_id"]),
                    "user_id": str(review["user_id"]),
                    "business_id": str(review["business_id"]),
                    "user_name": user_name,  
                    "business_name": businesses.get(str(review["business_id"]), "Unknown"),
                    "review_content": review["review_content"],
                    "rating": review["rating"],
                    "review_image": review["review_image"],  
                    "review_timestamp": review["review_timestamp"],
                })

            return result if result else []

        except Exception as e:
            print("Error:", str(e))  
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
                            "user_vote": -1,
                            "meal": review["meal"],
                            "accommodations": review["accommodations"]
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
                            "user_vote": 1,
                            "meal": review["meal"],
                            "accommodations": review["accommodations"]
                            
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
                        "meal": review["meal"],
                        "accommodations": review["accommodations"]
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
            print(vote.vote)
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



    async def delete_review(self, review_id: str):
        try:
            result = await self.db.user_reviews.delete_one({"_id": ObjectId(review_id)})
            return result.deleted_count > 0  
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    from bson import ObjectId

    async def edit_review(self, review_id: str, review_update: ReviewCreate):
        try:
            update_fields = {
                    k: (ObjectId(v) if k in ["user_id", "business_id"] and v is not None else v)
                    for k, v in review_update.dict().items() if v is not None
                }
            update_fields["review_timestamp"] = time.time()
            result = await self.db.user_reviews.find_one_and_update(
                {"_id": ObjectId(review_id)},
                {"$set": update_fields},
                return_document=True
            )
            if not result:
                return None
            
            # Convert the ObjectId to string before returning
            result["user_id"] = str(result["user_id"])  # Convert the ObjectId to string
            result["business_id"] = str(result["business_id"])
            result["_id"] = str(result["_id"])
            return result  
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        
    async def report_review(self, report_review: ReportReview):
        sg = sendgrid.SendGridAPIClient(api_key=settings.SENDGRID_KEY)
        to_email = To("safeeats.dev@gmail.com")
        from_email = Email("safeeats.noreply@gmail.com")
        review = await self.db.user_reviews.find_one({"_id": ObjectId(report_review.review_id)})
        # Check if the review exists
        if not review:
            raise HTTPException(status_code=404, detail="Review not found")
        subject = f"{report_review.user_name} has reported a review"
        content = Content("text/plain", f"Review ID: {str(review['_id'])} \n\nReview Content: {review['review_content']}\n\nReporter: {report_review.user_name}\n\nReason for Reporting: {report_review.message}")
        mail = Mail(from_email, to_email, subject, content)
        try:
            response = sg.send(mail)
        except:
            return None
        
        return(response.status_code, response.body, response.headers)



        
    async def get_detailed_review(self, review_id: str):
        review = await self.db.user_reviews.find_one({"_id": ObjectId(review_id)})
        if not review:
            return None
        review["_id"] = str(review["_id"])
        review["user_id"] = str(review["user_id"]) 
        review["business_id"] = str(review["business_id"]) 
        user = await self.db.users.find_one({"_id": ObjectId(review["user_id"])})
        business = await self.db.businesses.find_one({"_id": ObjectId(review["business_id"])})
        review["business_name"] = business["name"]
        review["user_name"] = user["name"]
        review_image_cursor = await self.db.review_images.find_one({"review_id": ObjectId(review_id)})
        if review_image_cursor and review_image_cursor:
            review["review_image"] = review_image_cursor["review_image"]
            
        review["_id"] = str(review["_id"]) 
        return review

