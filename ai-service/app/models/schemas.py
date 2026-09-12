from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

class RoomAnalysisResponse(BaseModel):
    detected_room_type: str = Field(..., description="Detected architectural room category")
    detected_style: str = Field(..., description="Dominant interior design style")
    dominant_colors: List[str] = Field(default_factory=list, description="Extracted dominant HEX color palette")
    detected_objects: List[str] = Field(default_factory=list, description="Visual constraints and objects detected")
    visual_clutter: str = Field(default="Low", description="Clutter level: Low, Medium, or High")
    confidence: float = Field(default=0.85, description="Perception confidence between 0.0 and 1.0")
    provider: str = Field(..., description="AI provider used: gemini, rule_based, or mock")
    is_mock: bool = Field(default=False, description="True if mock/fallback was invoked")
    summary: Optional[str] = Field(default=None, description="Perceptual analysis summary")

class RoomDimensions(BaseModel):
    width_cm: float = 400.0
    length_cm: float = 500.0
    height_cm: float = 280.0

class RecommendationRequest(BaseModel):
    room_type: str = Field(default="Living Room")
    style: Optional[str] = Field(default=None)
    dominant_colors: List[str] = Field(default_factory=list)
    room_dimensions: Optional[RoomDimensions] = None
    existing_furniture_ids: List[int] = Field(default_factory=list)
    catalog: List[Dict[str, Any]] = Field(default_factory=list, description="Active furniture catalog pieces")

class FurnitureRecommendation(BaseModel):
    furniture_id: int
    score: float = Field(..., ge=0.0, le=1.0)
    match_reasons: List[str] = Field(default_factory=list)
    aesthetic_notes: Optional[str] = None

class RecommendationResponse(BaseModel):
    recommendations: List[FurnitureRecommendation] = Field(default_factory=list)
    target_style: str
    target_palette: List[str] = Field(default_factory=list)
    provider: str
    is_mock: bool = False
