from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form
from services.menu_service import MenuService
from schemas.menu import MenuResponse
from schemas.ocr_results import OcrResult
import uuid

router = APIRouter()

menu_service = MenuService()

@router.post("/upload_official")
async def process_official_menu(business_id: str = Form(...), file: UploadFile = File(...)):
    """
    Process the uploaded official menu image and return OCR results.
    """
    try:
        contents = await file.read()
        image_path = f"/tmp/{uuid.uuid4()}.jpg"
        with open(image_path, "wb") as image_file:
            image_file.write(contents)
        ocr_results = await menu_service.process_image(image_path, business_id, is_official=True)
        return MenuResponse(**ocr_results)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/upload")
async def process_menu(business_id: str = Form(...), file: UploadFile = File(...)):
    """
    Process the uploaded menu image and return OCR results.
    """
    try:
        contents = await file.read()
        image_path = f"/tmp/{uuid.uuid4()}.jpg"
        with open(image_path, "wb") as image_file:
            image_file.write(contents)
        ocr_results = await menu_service.process_image(image_path, business_id, is_official=False)
        return MenuResponse(**ocr_results)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))