from bson import ObjectId
import time

class Friend():
    def __init__(self, user_id: ObjectId, friend_id: ObjectId, friend_since: float = time.time()):
        self.user_id = user_id
        self.friend_id = friend_id
        self.friend_since = friend_since 
    def to_dict(self):
        return {
            "user_id": self.user_id,
            "friend_id": self.friend_id,
            "friend_since": self.friend_since
        }