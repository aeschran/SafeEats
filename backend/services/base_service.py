from db.init_db import db

class BaseService:
    def __init__(self):
        self.db = db