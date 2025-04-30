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

class Sender(BaseModel):
    id: PyObjectId = Field(..., alias="_id")
    name: str

class NotificationResponse(BaseModel):
    notification_id: PyObjectId
    recipient_id: PyObjectId
    sender_id: PyObjectId
    sender_username: str  # Add sender_name to the response model
    type: NotificationEnum
    content: str = None
    timestamp: float

class CreateNotificationResponse(BaseModel):
    recipient_id: PyObjectId
    sender_id: PyObjectId
    type: NotificationEnum
    content: str = None
    timestamp: float


# class NotificationResponse(BaseModel):
#     recipient_id: PyObjectId
#     sender: Sender
#     type: NotificationEnum
#     content: str = None
#     timestamp: float

    class Config:
        arbitrary_types_allowed = True
        