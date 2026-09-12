from fastapi import APIRouter
from app.core.config import settings

router = APIRouter(tags=["Health"])

@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "SmartSpace AI Microservice",
        "active_provider": settings.ACTIVE_PROVIDER,
        "gemini_configured": bool(settings.GEMINI_API_KEY),
    }
