import pytest
import io
from PIL import Image
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def create_sample_image() -> bytes:
    """Generate a valid test JPEG image in memory."""
    img = Image.new("RGB", (100, 100), color=(230, 220, 200))
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG")
    return buffer.getvalue()

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "active_provider" in data

def test_analyze_room_endpoint():
    img_bytes = create_sample_image()
    files = {"file": ("room_test.jpg", img_bytes, "image/jpeg")}
    data = {"hint": "Living Room"}
    
    response = client.post("/api/v1/analyze-room", files=files, data=data)
    assert response.status_code == 200
    result = response.json()
    
    assert "detected_room_type" in result
    assert "detected_style" in result
    assert "dominant_colors" in result
    assert isinstance(result["dominant_colors"], list)
    assert len(result["dominant_colors"]) > 0
    assert "confidence" in result
    assert "provider" in result

def test_recommendations_endpoint():
    payload = {
        "room_type": "Living Room",
        "style": "Scandinavian",
        "dominant_colors": ["#EAE6DF", "#173F35"],
        "room_dimensions": {
            "width_cm": 420.0,
            "length_cm": 500.0,
            "height_cm": 280.0
        },
        "existing_furniture_ids": [1],
        "catalog": [
            {
                "id": 1,
                "name": "Nordik 3-Seater Sofa",
                "style": "Scandinavian",
                "category_slug": "sofas",
                "price": 1250.00
            },
            {
                "id": 2,
                "name": "Aura Oval Coffee Table",
                "style": "Scandinavian",
                "category_slug": "coffee-tables",
                "price": 380.00
            },
            {
                "id": 3,
                "name": "Oslo Low Media Bench",
                "style": "Minimalist",
                "category_slug": "storage",
                "price": 460.00
            }
        ]
    }
    
    response = client.post("/api/v1/recommendations", json=payload)
    assert response.status_code == 200
    result = response.json()
    
    assert "recommendations" in result
    assert "target_style" in result
    # Furniture 1 should be excluded because it's in existing_furniture_ids
    rec_ids = [r["furniture_id"] for r in result["recommendations"]]
    assert 1 not in rec_ids
    assert 2 in rec_ids
