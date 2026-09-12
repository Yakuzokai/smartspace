import random
from app.services.providers.base import BaseAIProvider
from app.models.schemas import (
    RoomAnalysisResponse,
    RecommendationRequest,
    RecommendationResponse,
    FurnitureRecommendation,
)

class MockProvider(BaseAIProvider):
    name = "mock"

    async def analyze_room(
        self,
        image_bytes: bytes,
        filename: str,
        hint: str | None = None
    ) -> RoomAnalysisResponse:
        """Deterministic demonstration provider for room photo vision analysis."""
        room_type = hint if hint and hint != "auto" else "Living Room"
        
        # Curated architectural palettes that match SmartSpace aesthetic
        palettes = [
            ["#EAE6DF", "#173F35", "#D8B98A", "#252A27"],
            ["#F7F4EE", "#3D4A41", "#C49A6C", "#737A76"],
            ["#EDEDE8", "#24332C", "#DEB887", "#333333"],
        ]
        chosen_palette = palettes[0]

        detected_objects = [
            "Hardwood floor",
            "Natural window lighting",
            "Neutral perimeter walls",
            "Subtle architectural moldings",
        ]

        return RoomAnalysisResponse(
            detected_room_type=room_type,
            detected_style="Scandinavian",
            dominant_colors=chosen_palette,
            detected_objects=detected_objects,
            visual_clutter="Low",
            confidence=0.95,
            provider="mock",
            is_mock=True,
            summary=(
                "Demonstration perception: Identified an open living layout with warm natural lighting, "
                "oak wood flooring, and light-reflecting perimeter walls. Strong affinity for Scandinavian "
                "and Japandi organic minimalism."
            ),
        )

    async def recommend(
        self,
        request: RecommendationRequest
    ) -> RecommendationResponse:
        """Deterministic demonstration provider for style-matched recommendations."""
        target_style = request.style or "Scandinavian"
        target_palette = request.dominant_colors or ["#EAE6DF", "#173F35", "#D8B98A"]

        recommendations: list[FurnitureRecommendation] = []

        for item in request.catalog:
            item_id = item.get("id")
            if not item_id:
                continue

            # Skip items already placed in the room
            if item_id in request.existing_furniture_ids:
                continue

            item_style = item.get("style", "")
            category = item.get("category_slug", "") or item.get("category", {}).get("slug", "")

            # Compute style affinity
            score = 0.70
            reasons = []

            if item_style.lower() == target_style.lower():
                score += 0.20
                reasons.append(f"Direct match with detected {target_style} aesthetic")
            elif item_style.lower() in ["minimalist", "japandi", "contemporary"]:
                score += 0.15
                reasons.append(f"Complementary modern architectural lines ({item_style})")

            # Check room type alignment
            if "living" in request.room_type.lower() and any(c in category for c in ["sofa", "table", "chair", "storage", "living"]):
                score += 0.08
                reasons.append(f"Harmonizes with {request.room_type} spatial zoning")
            elif "bed" in request.room_type.lower() and any(c in category for c in ["bed", "nightstand", "wardrobe"]):
                score += 0.08
                reasons.append(f"Harmonizes with {request.room_type} spatial zoning")

            reasons.append("Balances tone with detected room color palette")
            final_score = min(0.98, round(score, 2))

            recommendations.append(
                FurnitureRecommendation(
                    furniture_id=item_id,
                    score=final_score,
                    match_reasons=reasons,
                    aesthetic_notes=f"Selected for proportion and material compatibility with {target_style} interiors.",
                )
            )

        # Sort descending by score
        recommendations.sort(key=lambda r: r.score, reverse=True)

        return RecommendationResponse(
            recommendations=recommendations[:10],
            target_style=target_style,
            target_palette=target_palette,
            provider="mock",
            is_mock=True,
        )
