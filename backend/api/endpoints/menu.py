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
        print("In upolad official menu")
        ocr_results = await menu_service.process_image(image_path, business_id, is_official=True)
        return {"message": "Image processed successfully"}
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
        return {"message": "Image processed successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.post("/upload_url")
async def process_menu_url(business_id: str = Form(...), url: str = Form(...)):
    """
    Process the uploaded menu image URL and return OCR results.
    """
    try:
        url_results = await menu_service.save_url_to_db(url, business_id)
        return {"message": "URL saved successfully", "url_results": url_results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/get_menu/{business_id}")
async def get_menu(business_id: str):
    """
    Get the menu for a specific business.
    """
    try:
        menu = await menu_service.get_unofficial_menu(business_id)
        if not menu:
            raise HTTPException(status_code=404, detail="Menu not found")
        return MenuResponse(**menu)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/get_official_menu/{business_id}")
async def get_official_menu(business_id: str):
    """
    Get the menu for a specific business.
    """
    try:
        menu = await menu_service.get_official_menu(business_id)
        if not menu:
            raise HTTPException(status_code=404, detail="Menu not found")
        return MenuResponse(**menu)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))