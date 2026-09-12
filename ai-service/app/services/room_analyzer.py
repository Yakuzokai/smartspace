import logging
from app.core.config import settings
from app.models.schemas import RoomAnalysisResponse
from app.services.providers.gemini_provider import GeminiProvider
from app.services.providers.rule_based import RuleBasedProvider
from app.services.providers.mock_provider import MockProvider

logger = logging.getLogger("smartspace.room_analyzer")

class RoomAnalyzerService:
    def __init__(self):
        self.mock_provider = MockProvider()
        self.rule_based_provider = RuleBasedProvider()
        self.gemini_provider = None
        if settings.GEMINI_API_KEY:
            try:
                self.gemini_provider = GeminiProvider(settings.GEMINI_API_KEY)
            except Exception as e:
                logger.warning(f"Could not initialize Gemini provider: {e}")

    async def analyze_room(
        self,
        image_bytes: bytes,
        filename: str,
        hint: str | None = None
    ) -> RoomAnalysisResponse:
        """
        Execute vision analysis with resilient fallback:
        Gemini (Real multimodal perception)
          -> Rule-Based (Deterministic degraded perception)
          -> Mock (Deterministic demonstration provider)
        """
        # 1. Primary: Gemini (if configured)
        if settings.ACTIVE_PROVIDER == "gemini" and self.gemini_provider:
            try:
                logger.info("Executing room vision analysis with Gemini 2.0 Flash...")
                return await self.gemini_provider.analyze_room(image_bytes, filename, hint)
            except Exception as e:
                logger.warning(f"Gemini perception failed ({e}). Falling back to Rule-Based provider.")

        # 2. Secondary: Rule-Based heuristic perception
        if settings.ACTIVE_PROVIDER in ["gemini", "rule_based"]:
            try:
                logger.info("Executing room vision analysis with Rule-Based provider...")
                return await self.rule_based_provider.analyze_room(image_bytes, filename, hint)
            except Exception as e:
                logger.warning(f"Rule-based perception failed ({e}). Falling back to Mock provider.")

        # 3. Final: Mock demonstration provider
        logger.info("Serving room vision analysis via Mock Demonstration provider.")
        return await self.mock_provider.analyze_room(image_bytes, filename, hint)

room_analyzer_service = RoomAnalyzerService()
