from models.comment import Comment
from schemas.comment import CommentCreate
from services.base_service import BaseService
from bson import ObjectId
from fastapi import HTTPException
import time


class CommentService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")

    async def create_comment(self, comment_create: CommentCreate):
        try:
            if comment_create.is_business:
                review = await self.db.user_reviews.find_one({"_id": ObjectId(comment_create.review_id)})
                if not review:
                    raise HTTPException(status_code=404, detail="Review not found.")

                business = await self.db.businesses.find_one({"_id": ObjectId(review["business_id"])})
                if not business:
                    raise HTTPException(status_code=404, detail="Business not found.")
                
                if str(business["owner_id"]) != str(comment_create.commenter_id):
                    raise HTTPException(
                        status_code=403,
                        detail="Business owner can only comment on reviews for businesses they own."
                    )
                is_trusted = False
            else:
                user = await self.db.users.find_one({"_id": ObjectId(comment_create.commenter_id)})
                if not user:
                    raise HTTPException(status_code=404, detail="Commenter not found.")
                is_trusted = user.get("trusted_reviewer", False)

            
            comment = Comment(
                review_id=ObjectId(comment_create.review_id),
                commenter_id=ObjectId(comment_create.commenter_id),
                is_business=comment_create.is_business,
                is_trusted=is_trusted,
                comment_content=comment_create.comment_content,
            )

            result = await self.db.comments.insert_one(comment.to_dict())
            if result.inserted_id:
                return str(result.inserted_id)
            return None

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")

    async def get_comments_for_review(self, review_id: str):
        try:
            print(f"review ID: {review_id}")
            comments_cursor = self.db.comments.find({"review_id": ObjectId(review_id)}).sort("comment_timestamp", 1)
            business_comments = []
            comments = []
            async for comment in comments_cursor:
                if comment["is_business"]:
                    business_owner = await self.db.business_owners.find_one({"_id": ObjectId(comment["commenter_id"])})
                    name = business_owner["name"]
                    comment["_id"] = str(comment["_id"])  
                    comment["review_id"] = str(comment["review_id"])
                    comment["commenter_id"] = str(comment["commenter_id"])
                    comment["commenter_username"] = name
                    comment["is_trusted"] = False
                    print(comment)
                    business_comments.append(comment)
                else:
                    user = await self.db.users.find_one({"_id": ObjectId(comment["commenter_id"])})
                    name = user["username"]
                    comment["_id"] = str(comment["_id"])  
                    comment["review_id"] = str(comment["review_id"])
                    comment["commenter_id"] = str(comment["commenter_id"])
                    comment["commenter_username"] = name
                    comment["is_trusted"] = user.get("trusted_reviewer", False)
                    print(comment)
                    comments.append(comment)
            return business_comments + comments
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get comments: {str(e)}")


    async def delete_comment(self, comment_id: str, user_id: str, is_business: bool):
        try:
            comment = await self.db.comments.find_one({"_id": ObjectId(comment_id)})
            if not comment:
                return False

            if str(comment["commenter_id"]) != user_id or comment["is_business"] != is_business:
                return False

            result = await self.db.comments.delete_one({"_id": ObjectId(comment_id)})
            return result.deleted_count > 0

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to delete comment: {str(e)}")
