from bson import ObjectId

class PyObjectId(str):
    """Custom class to serialize MongoDB's ObjectId"""
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return str(v)
    
    def str_to_object(cls, v):
        if type(v) is str:
            return ObjectId(v)