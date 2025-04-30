from fastapi import APIRouter, HTTPException
from schemas.comment import CommentCreate, CommentResponse
from services.comment_service import CommentService
from typing import List


router = APIRouter(tags=["Comment"])

comment_service = CommentService()

@router.post("/create", response_model=dict)
async def create_comment(comment_create: CommentCreate):
    comment_id = await comment_service.create_comment(comment_create)
    if not comment_id:
        raise HTTPException(status_code=500, detail="Failed to create comment")
    return {"comment_id": str(comment_id)}

@router.get("/{review_id}", response_model=List[CommentResponse])
async def get_comments(review_id: str):
    comments = await comment_service.get_comments_for_review(review_id)
    return comments

@router.delete("/{comment_id}", response_model=dict)
async def delete_comment(comment_id: str, user_id: str, is_business: bool):
    deleted = await comment_service.delete_comment(comment_id, user_id, is_business)
    if not deleted:
        raise HTTPException(status_code=404, detail="Comment not found or you don't have permission to delete it")
    return {"message": "Comment deleted successfully"}
