import logging
from app.core.config import settings
from app.models.schemas import RecommendationRequest, RecommendationResponse
from app.services.providers.gemini_provider import GeminiProvider
from app.services.providers.rule_based import RuleBasedProvider
from app.services.providers.mock_provider import MockProvider

logger = logging.getLogger("smartspace.recommender")

class RecommenderService:
    def __init__(self):
        self.mock_provider = MockProvider()
        self.rule_based_provider = RuleBasedProvider()
        self.gemini_provider = None
        if settings.GEMINI_API_KEY:
            try:
                self.gemini_provider = GeminiProvider(settings.GEMINI_API_KEY)
            except Exception as e:
                logger.warning(f"Could not initialize Gemini provider: {e}")

    async def recommend(self, request: RecommendationRequest) -> RecommendationResponse:
        """
        Execute aesthetic style recommendations with resilient fallback:
        Gemini -> Rule-Based -> Mock
        """
        # 1. Primary: Gemini
        if settings.ACTIVE_PROVIDER == "gemini" and self.gemini_provider:
            try:
                logger.info("Executing aesthetic recommendations with Gemini 2.0 Flash...")
                return await self.gemini_provider.recommend(request)
            except Exception as e:
                logger.warning(f"Gemini recommendations failed ({e}). Falling back to Rule-Based.")

        # 2. Secondary: Rule-Based
        if settings.ACTIVE_PROVIDER in ["gemini", "rule_based"]:
            try:
                logger.info("Executing aesthetic recommendations with Rule-Based provider...")
                return await self.rule_based_provider.recommend(request)
            except Exception as e:
                logger.warning(f"Rule-based recommendations failed ({e}). Falling back to Mock.")

        # 3. Final: Mock Demonstration
        logger.info("Serving recommendations via Mock Demonstration provider.")
        return await self.mock_provider.recommend(request)

recommender_service = RecommenderService()
