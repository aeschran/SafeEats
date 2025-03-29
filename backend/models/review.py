from bson import ObjectId
import time

class Review():
    def __init__(self, review_content: str, rating: int, review_image: str, user_id: ObjectId, business_id: ObjectId, review_timestamp: float = time.time()):
        self.user_id = user_id
        self.business_id = business_id
        self.review_timestamp = review_timestamp 
        self.review_content = review_content
        self.rating = rating
        self.review_image = review_image if review_image else None 

    def to_dict(self):
        review_data = {
            "user_id": self.user_id,
            "business_id": self.business_id,
            "review_timestamp": self.review_timestamp,
            "review_content": self.review_content,
            "rating": self.rating,
        }
        if self.review_image:  # Only include if not None or empty
            review_data["review_image"] = self.review_image
        return review_data