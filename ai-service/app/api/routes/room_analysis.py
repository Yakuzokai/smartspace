from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
from app.models.schemas import RoomAnalysisResponse
from app.services.room_analyzer import room_analyzer_service

router = APIRouter(tags=["Room Vision Analysis"])

@router.post("/analyze-room", response_model=RoomAnalysisResponse)
async def analyze_room(
    file: UploadFile = File(...),
    hint: Optional[str] = Form(None),
):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type '{file.content_type}'. Please upload an image (JPEG, PNG, WebP)."
        )

    image_bytes = await file.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Uploaded image is empty.")

    try:
        result = await room_analyzer_service.analyze_room(
            image_bytes=image_bytes,
            filename=file.filename or "room.jpg",
            hint=hint,
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Perception error: {str(e)}")
