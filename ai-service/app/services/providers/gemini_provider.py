import json
import logging
from google import genai
from google.genai import types
from app.services.providers.base import BaseAIProvider
from app.models.schemas import (
    RoomAnalysisResponse,
    RecommendationRequest,
    RecommendationResponse,
    FurnitureRecommendation,
)

logger = logging.getLogger("smartspace.gemini")

class GeminiProvider(BaseAIProvider):
    name = "gemini"

    def __init__(self, api_key: str):
        if not api_key:
            raise ValueError("GEMINI_API_KEY is not configured.")
        self.api_key = api_key
        self.client = genai.Client(api_key=api_key)

    async def analyze_room(
        self,
        image_bytes: bytes,
        filename: str,
        hint: str | None = None
    ) -> RoomAnalysisResponse:
        """Multimodal perception using Gemini 2.0 Flash structured JSON."""
        mime_type = "image/jpeg"
        if filename.lower().endswith(".png"):
            mime_type = "image/png"
        elif filename.lower().endswith(".webp"):
            mime_type = "image/webp"

        prompt = f"""You are an expert architectural interior designer analyzing a room photograph for the SmartSpace spatial planning system.
Extract the architectural perception strictly formatted as a JSON object:
- detected_room_type: One of "Living Room", "Bedroom", "Home Office", "Dining Room", or "Studio"
- detected_style: Interior design style (e.g., "Scandinavian", "Minimalist", "Modern", "Industrial", "Japandi", "Contemporary")
- dominant_colors: Exactly 4 dominant HEX color codes (e.g. ["#EAE6DF", "#173F35", "#D8B98A", "#252A27"])
- detected_objects: List of visible physical elements, existing furniture, or structural elements (e.g. ["Window", "Hardwood floor", "Accent sofa"])
- visual_clutter: One of "Low", "Medium", "High"
- confidence: Float between 0.0 and 1.0 representing your perceptual confidence
- summary: A concise 2-sentence professional architectural observation of the space.

Context hint provided by user: {hint or 'None'}
"""

        try:
            response = self.client.models.generate_content(
                model="gemini-2.0-flash",
                contents=[
                    types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
                    prompt,
                ],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    temperature=0.2,
                ),
            )

            data = json.loads(response.text)
            return RoomAnalysisResponse(
                detected_room_type=data.get("detected_room_type", "Living Room"),
                detected_style=data.get("detected_style", "Scandinavian"),
                dominant_colors=data.get("dominant_colors", ["#EAE6DF", "#173F35", "#D8B98A", "#252A27"]),
                detected_objects=data.get("detected_objects", []),
                visual_clutter=data.get("visual_clutter", "Low"),
                confidence=float(data.get("confidence", 0.92)),
                provider="gemini",
                is_mock=False,
                summary=data.get("summary", "Gemini 2.0 Flash multimodal perception."),
            )
        except Exception as e:
            logger.warning(f"Gemini API error during room analysis: {e}")
            raise

    async def recommend(
        self,
        request: RecommendationRequest
    ) -> RecommendationResponse:
        """Aesthetic matching against catalog using Gemini 2.0 Flash."""
        target_style = request.style or "Scandinavian"
        target_palette = request.dominant_colors or ["#EAE6DF", "#173F35", "#D8B98A"]

        catalog_summary = [
            {
                "id": item.get("id"),
                "name": item.get("name"),
                "style": item.get("style"),
                "category": item.get("category_slug", "") or item.get("category", {}).get("slug", ""),
                "price": item.get("price"),
            }
            for item in request.catalog
            if item.get("id") not in request.existing_furniture_ids
        ]

        prompt = f"""You are the SmartSpace aesthetic recommendation engine.
Room Context:
- Room Type: {request.room_type}
- Target Style: {target_style}
- Dominant Palette: {', '.join(target_palette)}

Available furniture items:
{json.dumps(catalog_summary[:25])}

Select up to 8 items that best complement the room's aesthetic.
For each recommended item return:
- furniture_id (int)
- score (float 0.70 - 0.99)
- match_reasons (array of 2 concise architectural reasons)
- aesthetic_notes (brief sentence on styling rationale)

Return JSON formatted as:
{{
  "recommendations": [...]
}}
"""

        try:
            response = self.client.models.generate_content(
                model="gemini-2.0-flash",
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    temperature=0.3,
                ),
            )
            data = json.loads(response.text)
            recs = [
                FurnitureRecommendation(
                    furniture_id=int(r["furniture_id"]),
                    score=float(r["score"]),
                    match_reasons=r.get("match_reasons", []),
                    aesthetic_notes=r.get("aesthetic_notes", ""),
                )
                for r in data.get("recommendations", [])
                if "furniture_id" in r
            ]
            return RecommendationResponse(
                recommendations=recs,
                target_style=target_style,
                target_palette=target_palette,
                provider="gemini",
                is_mock=False,
            )
        except Exception as e:
            logger.warning(f"Gemini API error during recommendations: {e}")
            raise
