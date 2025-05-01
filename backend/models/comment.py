from pydantic import BaseModel
from typing import Optional, Dict, List
from utils.pyobjectid import PyObjectId
from bson import ObjectId
import time



class Comment:
    def __init__(self, review_id: str, commenter_id: str, is_business: bool, is_trusted: bool, comment_content: str, comment_timestamp: float = None):
        self.review_id = review_id  # Which review this comment belongs to
        self.commenter_id = commenter_id  # ID from either user or business owner
        self.is_business = is_business  # 'user' or 'business'
        self.is_trusted = is_trusted  # Whether the comment is from a trusted reviewer
        self.comment_content = comment_content
        self.comment_timestamp = comment_timestamp if comment_timestamp is not None else time.time()

    def to_dict(self):
        return {
            "review_id": self.review_id,
            "commenter_id": self.commenter_id,
            "is_business": self.is_business,
            "is_trusted": self.is_trusted,
            "comment_content": self.comment_content,
            "comment_timestamp": self.comment_timestamp
        }
