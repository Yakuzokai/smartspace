from fastapi import APIRouter, HTTPException
from app.models.schemas import RecommendationRequest, RecommendationResponse
from app.services.recommender import recommender_service

router = APIRouter(tags=["Recommendations"])

@router.post("/recommendations", response_model=RecommendationResponse)
async def get_recommendations(request: RecommendationRequest):
    try:
        return await recommender_service.recommend(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Recommendation error: {str(e)}")
