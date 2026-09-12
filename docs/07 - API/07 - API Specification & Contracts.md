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
* `GET  /api/v1/categories` — Hierarchical category tree with child subcategories.
* `GET  /api/v1/categories/{idOrSlug}` — Single category details with associated furniture count.
* `GET  /api/v1/furniture` — Filtered catalog search (`category_id`, `style`, `min_price`, `max_price`, `max_width_cm`, `max_depth_cm`, `max_height_cm`).
* `GET  /api/v1/furniture/featured` — Curated highlights for the landing page hero carousel.
* `GET  /api/v1/furniture/styles` — List of unique architectural styles present in catalog.
* `GET  /api/v1/furniture/{id}` — Single furniture item details, dimensions, multi-angle images, and 3D GLB model path.

### Room Projects (`/api/v1/room-projects`)
* `GET  /api/v1/room-projects` — List user's saved room designs.
* `POST /api/v1/room-projects` — Create a new room project with custom dimensions ($W \times L \times H$ in cm).
* `GET  /api/v1/room-projects/{id}` — Load room project with full furniture placements array, active score, and breakdown.
* `PUT  /api/v1/room-projects/{id}` — Update room metadata or dimensions.
* `PUT  /api/v1/room-projects/{id}/layout` — **Transactional 3D layout sync**: Accepts array of placed items ($X, Y, Z, \theta$), syncs placements in a database transaction, and automatically runs `SpaceCompatibilityService` certification.
* `POST /api/v1/room-projects/{id}/validate` — On-demand spatial validation returning instant 5-factor score without persisting.
* `DELETE /api/v1/room-projects/{id}` — Remove a room project and all associated placements.

### Customer Favorites (`/api/v1/favorites`)
* `GET  /api/v1/favorites` — List authenticated customer's favorited furniture items.
* `POST /api/v1/favorites/toggle/{furnitureId}` — Atomic toggle (add/remove) of a furniture item in favorites.

### AI Proxy & Recommendations (`/api/v1/ai`)
* `POST /api/v1/ai/analyze-room` — Upload room image $\rightarrow$ proxies to FastAPI $\rightarrow$ caches in `room_analyses`.
* `POST /api/v1/ai/recommendations` — Solicits furniture items matching room constraints.

### System Telemetry & Health (`/api/v1/system`)
* `GET  /api/v1/system/health` — **Gateway Subsystem Health Aggregator**: Centralized operational health and latency probe across Laravel API Gateway, MySQL PDO connection, Deterministic Spatial Compatibility Engine, and internal FastAPI AI Microservice (:8001). Frontend never accesses port 8001 directly.
  * **Sample Output Schema**:
    ```json
    {
      "status": "operational",
      "timestamp": "2026-09-13T01:25:00+08:00",
      "topology": "Vue 3 -> Laravel 11 Gateway -> FastAPI Microservice",
      "subsystems": {
        "gateway": {
          "name": "SmartSpace API Gateway",
          "status": "operational",
          "environment": "local",
          "php_version": "8.5.0",
          "laravel_version": "11.46.0",
          "latency_ms": 0.52
        },
        "database": {
          "name": "MySQL Relational Store",
          "status": "operational",
          "driver": "mysql",
          "database": "smartspace",
          "latency_ms": 1.15
        },
        "spatial_engine": {
          "name": "Deterministic Spatial Compatibility Service",
          "status": "operational",
          "algorithm": "Rotation-Aware Pairwise AABB Geometry",
          "evaluation_mode": "Deterministic Mathematics",
          "fixed_scale": "1.000 (Database-Authoritative)"
        },
        "ai_microservice": {
          "name": "FastAPI AI Perception & Recommendation Microservice",
          "status": "operational",
          "url": "http://127.0.0.1:8001",
          "latency_ms": 12.4,
          "provider": "rule_based",
          "resilience": "Graceful Degradation with Automatic Fallback"
        }
      }
    }
    ```

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
