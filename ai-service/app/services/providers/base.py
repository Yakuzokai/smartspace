from abc import ABC, abstractmethod
from app.models.schemas import RoomAnalysisResponse, RecommendationRequest, RecommendationResponse

class BaseAIProvider(ABC):
    name: str = "base"

    @abstractmethod
    async def analyze_room(
        self,
        image_bytes: bytes,
        filename: str,
        hint: str | None = None
    ) -> RoomAnalysisResponse:
        """Perform multimodal visual perception on uploaded room photograph."""
        pass

    @abstractmethod
    async def recommend(
        self,
        request: RecommendationRequest
    ) -> RecommendationResponse:
        """Recommend aesthetic matches based on room style and palette."""
        pass
