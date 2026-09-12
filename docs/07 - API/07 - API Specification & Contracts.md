---
title: "07 — API Specification & Contracts"
tags:
  - smartspace
  - api
  - endpoints
  - contracts
created: 2026-09-12
---

# 📡 07 — API Specification & Contracts

Back to [[00 - Home|🏠 Documentation Hub]]

---

## 1. Laravel 11 REST API Endpoints

### Authentication (`/api/v1/auth`)
* `POST /api/v1/auth/register` — Create a new customer account.
* `POST /api/v1/auth/login` — Authenticate and start Sanctum session.
* `POST /api/v1/auth/logout` — Revoke session cookie.
* `GET  /api/v1/auth/me` — Return authenticated user profile and active role.

### Furniture Catalog (`/api/v1/furniture`)
* `GET  /api/v1/categories` — Category tree with parent/child structure.
* `GET  /api/v1/furniture` — Filtered catalog search (`category_id`, `style`, `min_price`, `max_width`, etc.).
* `GET  /api/v1/furniture/{id}` — Single furniture item details, dimensions, and 3D GLB model path.

### Room Projects (`/api/v1/room-projects`)
* `GET  /api/v1/room-projects` — List user's saved room designs.
* `POST /api/v1/room-projects` — Create a new room project.
* `GET  /api/v1/room-projects/{id}` — Load room project with full furniture placements array.
* `PUT  /api/v1/room-projects/{id}` — Update room dimensions or furniture layout.
* `DELETE /api/v1/room-projects/{id}` — Remove a room project.

### AI Proxy & Recommendations (`/api/v1/ai`)
* `POST /api/v1/ai/analyze-room` — Upload room image $\rightarrow$ proxies to FastAPI $\rightarrow$ caches in `room_analyses`.
* `POST /api/v1/ai/recommendations` — Solicits furniture items matching room constraints.

---

## 2. FastAPI AI Service Contracts

### `POST /api/v1/analyze-room`
* **Input**: Multipart Form (`image` file, `room_type_hint` string optional).
* **Output Schema**:
  ```json
  {
    "detected_room_type": "Living Room",
    "detected_style": "Scandinavian",
    "dominant_colors": ["#E5E0D8", "#4A5568", "#D97706"],
    "visual_clutter": "Low",
    "confidence": 0.92,
    "provider": "gemini",
    "_mock": false
  }
  ```

### `POST /api/v1/recommendations`
* **Input**: JSON payload containing `room_type`, `style`, `dimensions` ($W \times L$), and `existing_furniture_ids`.
* **Output Schema**: Array of recommended furniture IDs paired with relevance scores and match rationales.
