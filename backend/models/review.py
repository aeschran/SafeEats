from bson import ObjectId
import time

class Review():
    def __init__(self, review_content: str, rating: int, user_id: ObjectId, business_id: ObjectId, review_timestamp: float = None, upvotes = 0, downvotes = 0):
        self.user_id = user_id
        self.business_id = business_id
        self.review_timestamp = review_timestamp if review_timestamp is not None else time.time()
        self.review_content = review_content
        self.rating = rating
        self.upvotes = 0
        self.downvotes = 0

    def to_dict(self):
        review_data = {
            "user_id": self.user_id,
            "business_id": self.business_id,
            "review_timestamp": self.review_timestamp,
            "review_content": self.review_content,
            "rating": self.rating,
            "upvotes": self.upvotes,
            "downvotes": self.downvotes
        }
        # if self.review_image:  # Only include if not None or empty
        #     review_data["review_image"] = self.review_image
        return review_data
    
class ReviewVote():
    def __init__(self, review_id: ObjectId, user_id: ObjectId, vote: int):
        self.review_id = review_id
        self.user_id = user_id
        self.vote = vote
    def to_dict(self):
        return {
            "user_id": self.user_id,
            "review_id": self.review_id,
            "vote": self.vote
        }
    
class ReviewAddImage():

    def __init__(self, review_id: ObjectId, review_image: str):
        self.review_id = review_id
        self.review_image = review_image

    def to_dict(self):
        return {
            "review_id": self.review_id,
            "review_image": self.review_image
        }