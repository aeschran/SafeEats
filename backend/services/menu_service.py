import easyocr
from PIL import Image, ImageDraw
from services.base_service import BaseService
from schemas.ocr_results import OcrResult
from models.menu import Menu
import re
from collections import defaultdict
import datetime
from utils.upload_to_s3 import S3Client
import os
from bson import ObjectId

class MenuService(BaseService):
    def __init__(self):
        super().__init__()
        if self.db is None:
            raise Exception("Database connection failed.")
        self.reader = easyocr.Reader(['en'], gpu=False)  # Initialize the OCR reader
        self.keywords = {
            "halal": {"pork", "frog", "ham", "carrion", "beer", "wine", "pig", "bacon"},
            "vegetarian": {"meat", "fish", "chicken", "pork", "beef", "seafood", "ham", "steak", "duck", "lamb", "poultry", "turkey", "rabbit", "squid", "octopus", "crab", "lobster", "shrimp", "shellfish", "salmon", "tuna", "goat", "veal", "bacon", "sausage", "chorizo", "pepperoni", "salami", "prosciutto", "venison"},
            "vegan": {"egg", "milk", "buttermilk", "cheese", "butter", "yogurt", "honey", "gelatin", "cream", "mayonnaise", "sour cream", "whey", "meat", "fish", "chicken", "pork", "beef", "seafood", "ham", "steak", "duck", "lamb", "poultry", "turkey", "rabbit", "squid", "octopus", "crab", "lobster", "shrimp", "shellfish", "salmon", "tuna", "goat", "veal", "bacon", "sausage", "chorizo", "pepperoni", "salami", "prosciutto", "venison",},
            "gluten_free": {"wheat", "barley", "bread", "pasta", "cereal", "cake", "cookies", "crackers", "beer", "malt", "bun"},
            "dairy_free": {"milk", "cheese", "butter", "yogurt", "cream", "sour cream", "ice cream", "whey", "casein", "icecream", "buttermilk"},
            "peanut_free": {"peanut", "groundnut", "monkey nut", "nut"},
            "kosher": {"pork", "shellfish", "lobster", "crab", "shrimp", "squid", "octopus", "ham", "bacon", "sausage", "chorizo", "pepperoni", "salami", "prosciutto", "venison"},
            "shellfish_free": {"shrimp", "crab", "lobster", "squid", "octopus", "shellfish"},
        }
        self.conflict_map = self.build_reverse_index()

    def build_reverse_index(self):
        index = defaultdict(set)
        for restriction, words in self.keywords.items():
            for word in words:
                index[word].add(restriction)
        return index

    def normalize(self, text):
        return re.sub(r"[^\w\s]", "", text.lower())

    def match(self, word):
        norm = self.normalize(word)
        return self.conflict_map.get(norm, set())

    async def process_image(self, image_path: str, business_id: str, is_official: bool):
        with open(image_path, "rb") as image_file:
            image = Image.open(image_path)
        draw = ImageDraw.Draw(image)
        results = self.reader.readtext(image_path, detail=1)


        ocr_results = []

        for (bbox, text, prob) in results:
            tokens = self.normalize(text).split()
            for token in tokens:
                conflict = self.match(token)
                if conflict:
                    clean_bbox = [[int(coord) for coord in point] for point in bbox]
                    ocr_results.append({
                        "bbox": clean_bbox,
                        "conflict": list(conflict)
                    })
                    

        # Save the image with bounding boxes
        output_image_path = image_path.replace(".jpg", "_output.jpg")
        image.save(output_image_path)

        # Upload the image to S3
        s3_client = S3Client()
        output_image_path_s3 = s3_client.upload_image_to_s3(output_image_path, folder="menus")
        # Clean up the local file
        os.remove(image_path)
        os.remove(output_image_path)

        result = {
            "ocr_results": ocr_results,
            "image_url": output_image_path_s3,
            "created_at": str(datetime.datetime.now()),
            "image_width": image.width,
            "image_height": image.height,
            "is_official": is_official
        }
        print("made it here")
        # Save to database
        await self.save_to_db(ObjectId(business_id), ocr_results, output_image_path_s3, result["created_at"], image.width, image.height, is_official)
        return result
    
    async def save_url_to_db(self, url: str, business_id: str):
        """
        Save the image URL to the database.
        """
        result = await self.db.businesses.find_one({"_id": ObjectId(business_id)})
        if not result:
            raise Exception("Business not found")
        await self.db.businesses.update_one(
            {"_id": ObjectId(business_id)},
            {"$set": {"menu": url}}
        )
        return {"message": "URL saved successfully"}
    
    async def get_unofficial_menu(self, business_id: str):
        """
        Get the unofficial menu for a specific business.
        """
        print(business_id)
        result = await self.db.menu.find_one({"business_id": ObjectId(business_id), "is_official": False})
        if not result:
            raise Exception("Menu not found")
        return result
    
    async def save_to_db(self, business_id: str, ocr_results: list[OcrResult], image_url: str, created_at: str, image_width: int, image_height: int, is_official: bool):
        """
        Save the OCR results to the database.
        """
        menu = Menu(business_id=ObjectId(business_id), ocr_results=ocr_results, image_url=image_url, created_at=created_at, image_width=image_width, image_height=image_height, is_official=is_official)
        result = await self.db.menu.insert_one(menu.to_dict())
        return result
