---
title: "02 — Services Overview"
tags:
  - smartspace
  - services
  - microservices
created: 2026-09-12
---

# ⚙️ 02 — Services Overview

Back to [[00 - Home|🏠 Documentation Hub]]

---

## 1. Service Breakdown

SmartSpace is divided into three primary services, each with strict domain boundaries:

```
SmartSpace Ecosystem
├── 1. Frontend Service (Vue 3 + TypeScript + Three.js)
├── 2. Core Backend Service (Laravel 11 API)
└── 3. AI Microservice (Python FastAPI)
```

---

## 2. Frontend Service (`frontend/`)

* **Technology Stack**: Vue 3 (Composition API), TypeScript, Vite, Tailwind CSS, Three.js.
* **Key Responsibilities**:
  * **Interactive 3D Viewport**: Rendering real-world rooms with meter-accurate furniture models (`RoomCanvas.vue`).
  * **User Manipulation**: 3D raycasting, drag, drop, rotate, and elevation controls.
  * **Real-time UX HUD**: Client-side preview computation (`useSpaceCompatibility.ts`) for instant visual feedback on collisions and boundary breaches.
  * **State Management**: Pinia stores for user auth, active room project, catalog filters, and wishlist.

---

## 3. Core Backend Service (`backend/`)

* **Technology Stack**: Laravel 11, PHP 8.3+, Laravel Sanctum, MySQL 8.0.
* **Key Responsibilities**:
  * **Authentication & RBAC**: Cookie-based SPA authentication and role enforcement (`admin`, `customer`).
  * **Authoritative Geometry Engine**: `SpaceCompatibilityService.php` calculates the official 0–100% space compatibility score and structured explanation.
  * **Data Persistence**: Storing user accounts, categories, furniture specs, room projects, and 3D coordinate placements.
  * **AI Microservice Gateway**: Proxies room photo uploads and recommendation requests to the Python FastAPI microservice via `AIServiceClient.php`.

---

## 4. AI Microservice (`ai-service/`)

* **Technology Stack**: Python 3.11+, FastAPI, Pydantic v2, Uvicorn, Google GenAI SDK.
* **Key Responsibilities**:
  * **Perceptual Vision Analysis**: Multimodal analysis of user-uploaded room photos (detecting room type, design style, palette).
  * **Style Matching & Constraints**: Suggesting furniture styles and color palettes that complement the detected room aesthetic.
  * **Provider Abstraction**: Abstract `AIProvider` base class with pluggable implementations:
    * `gemini_provider.py` (Live Gemini 2.0 Flash)
    * `rule_based.py` (Deterministic heuristic backup)
    * `mock_provider.py` (Zero-config offline mock)
