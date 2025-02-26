# Notification model
from bson import ObjectId
from utils.enums import NotificationEnum
import time

class Notification():
    def __init__(self, sender_id: ObjectId, recipient_id: ObjectId, type: NotificationEnum, content: str, timestamp: float = time.time()):
        self.sender_id = sender_id
        self.recipient_id = recipient_id
        self.type = type
        self.content = content
        self.timestamp = timestamp
    def to_dict(self):
        return {
            "sender_id": self.sender_id,
            "recipient_id": self.recipient_id,
            "type": self.type.value,
            "content": self.content,
            "timestamp": self.timestamp
        }
