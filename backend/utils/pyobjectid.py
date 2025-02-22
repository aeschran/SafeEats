from bson import ObjectId

class PyObjectId(str):
    """Custom class to serialize MongoDB's ObjectId""" 
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v, values=None):  # Add 'values=None' to handle extra arguments
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return str(v)