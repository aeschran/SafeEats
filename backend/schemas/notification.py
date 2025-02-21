from bson import ObjectId
from pydantic import BaseModel, Field
from utils.pyobjectid import PyObjectId
from utils.enums import NotificationEnum

class NotificationCreate(BaseModel):
    sender_id: str
    recipient_id: str
    type: NotificationEnum
    content: str
    timestamp: float

class NotificationResponse(BaseModel):
    sender_id: PyObjectId
    recipient_id: PyObjectId
    type: NotificationEnum
    content: str
    timestamp: float