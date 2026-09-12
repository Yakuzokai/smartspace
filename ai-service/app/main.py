import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routes import health, room_analysis, recommendations

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)

app = FastAPI(
    title="SmartSpace AI Microservice",
    description="Multimodal Room Vision Perception & Style Recommendation Microservice",
    version="1.0.0",
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes
app.include_router(health.router)
app.include_router(health.router, prefix="/api/v1")
app.include_router(room_analysis.router, prefix="/api/v1")
app.include_router(recommendations.router, prefix="/api/v1")

@app.get("/")
async def root():
    return {
        "service": "SmartSpace AI Microservice",
        "status": "operational",
        "docs": "/docs",
        "active_provider": settings.ACTIVE_PROVIDER,
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True,
    )
