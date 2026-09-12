# 📋 SmartSpace — Project Updates & Architecture Log

**Document Version:** 1.0.0  
**Last Updated:** September 12, 2026  
**Status:** Baseline Locked & Initial File Structure Scaffolded  

---

## 📌 Executive Summary of Recent Updates

This document tracks major architectural decisions, scoping refinements, and milestone progress for the **SmartSpace** capstone project.

Following an in-depth architectural review, the project scope has transitioned from a broad, unwieldy e-commerce system into a tightly scoped, academically defensible capstone system:

> ### 🎯 Locked Research Thesis
> **"AI-Assisted Personalized Furniture Selection and Spatial Planning System"**  
> *Core Innovation:* AI furniture recommendations and layout suggestions are strictly **constrained by real physical geometry** (room boundaries, clearances, and collision tests), backed by a deterministic, explainable compatibility engine and a zero-downtime multi-provider AI architecture (Gemini + Rule-Based + Mock Fallback).

---

## 🔒 The 4 Architectural Locks

### 1. Two-Layer Space Compatibility Engine
* **Frontend (`useSpaceCompatibility.ts`)**: Fast, optimistic client-side preview running in the Three.js render loop to provide immediate 60 FPS feedback (HUD, warning outlines) during drag-and-drop manipulation.
* **Backend (`SpaceCompatibilityService.php`)**: The **authoritative single source of truth**. When a room design is saved or submitted for formal validation, Laravel re-calculates and persists the final certified compatibility score.

### 2. Realistic AI Room Perception Contract
* **User-Provided Measurements**: Authoritative ground truth for room width, length, and height ($W \times L \times H$ in cm). The system avoids unprovable claims of extracting millimeter-perfect dimensions from ordinary 2D smartphone photos.
* **AI Vision Output (Gemini 2.0 Flash)**: Strictly provides **estimated perceptual and contextual data**:
  * Detected room type (e.g., Living Room, Bedroom, Studio)
  * Architectural/interior style (e.g., Minimalist, Scandinavian, Industrial)
  * Dominant color palette (HEX values)
  * Detected existing furniture and visual constraints/clutter
  * Perception confidence score ($0.0 - 1.0$)

### 3. Explainable Space Compatibility Scoring
Rather than an arbitrary black-box percentage, the compatibility score is fully explainable for academic evaluation and user trust:
$$\text{Compatibility Score} = \text{Boundary Fit}\ (30\%) + \text{Clearance}\ (25\%) + \text{Collision Test}\ (25\%) + \text{Circulation}\ (10\%) + \text{Room Fitness}\ (10\%)$$

* **Score Breakdown Breakdown**:
  * **Boundary Fit (30 pts)**: Penalized to zero if any bounding volume exceeds room perimeter walls.
  * **Clearance (25 pts)**: Ensures functional access ($\ge 75\text{ cm}$ front walking clearance, $\ge 60\text{ cm}$ side clearance).
  * **No Overlap (25 pts)**: Strict 3D Axis-Aligned Bounding Box (AABB) intersection check; any intersection fails this component.
  * **Circulation / Utilization (10 pts)**: Floor area ratio ensuring $\ge 40\%$ unencumbered walking path.
  * **Room Type Appropriateness (10 pts)**: Category alignment with the designated room type.

### 4. 100% Order-Free / E-Commerce-Free MVP
All checkout pipelines, payment gateways, complex inventory warehouse tracking, and multi-tier executive audit logs have been deferred. The database is strictly trimmed to **10 lean tables** centered entirely on the core loop:
```
Browse Catalog → Define/Analyze Space → Filter/Recommend → 3D Interactive Placement → Geometry Validation → Save Design & Favorites
```

---

## 🗄️ Lean Database Schema (10 MVP Tables)

| # | Table Name | Purpose / Role in MVP |
|:---|:---|:---|
| 1 | `roles` | `admin`, `customer` role classification |
| 2 | `users` | Customer and administrator authentication (Laravel Sanctum) |
| 3 | `categories` | Hierarchical furniture categorization (Living Room, Bedroom, etc.) |
| 4 | `furniture` | Catalog items with physical dimensions ($W, H, D$), style, and GLB paths |
| 5 | `furniture_images`| Primary and gallery visual assets |
| 6 | `furniture_models`| 3D asset metadata (format, file size, Draco optimization flags) |
| 7 | `room_projects` | User room layouts (dimensions, user style preference, certified score) |
| 8 | `room_project_furniture` | Spatial placement records ($X, Y, Z$, rotation angle, scale) |
| 9 | `room_analyses` | Vision perception cache from AI microservice |
| 10 | `favorites` | Customer saved items / wishlist |

---

## 🔄 Technical Architecture Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                   Vue 3 + TypeScript Frontend                    │
│                                                                  │
│  [Catalog]  [Room Setup]  [3D Room Planner]  [Compatibility HUD] │
│                           └──────────┬──────────┘                │
│                                      │ Three.js                  │
│                        ⚡ Client Preview Calculation             │
└──────────────────────────────────────┬───────────────────────────┘
                                       │ REST API (JSON)
                                       ▼
┌──────────────────────────────────────────────────────────────────┐
│                         Laravel 11 API                           │
│                                                                  │
│  [Auth]  [Catalog API]  [Project Storage]  [Favorites]           │
│  ⚖️ SpaceCompatibilityService (Authoritative Geometry Engine)    │
│  🛡️ AIServiceClient (HTTP Proxy to Python FastAPI)              │
└──────────────┬───────────────────────────────────┬───────────────┘
               │ Eloquent ORM                      │ Internal HTTP Proxy
               ▼                                   ▼
┌───────────────────────────────┐   ┌──────────────────────────────┐
│           MySQL 8.0           │   │    Python FastAPI Microservice│
│                               │   │                              │
│  • Users       • Furniture    │   │  • Vision Room Analysis      │
│  • Categories  • RoomProjects │   │  • Style Detection           │
│  • Placements  • Favorites    │   │  • Geometry-Constrained Recs │
└───────────────────────────────┘   └──────────────┬───────────────┘
                                                   │
                                     ┌─────────────▼──────────────┐
                                     │    AI Provider Layer       │
                                     │  1. Gemini 2.0 Flash       │
                                     │  2. Rule-Based Fallback    │
                                     │  3. Mock Provider (Demo)   │
                                     └────────────────────────────┘
```

---

## 📅 Development Roadmap & Milestone Tracker

- [x] **Milestone 0: Architecture Finalization & File Scaffolding**
  - [x] Architectural pivot to spatial geometry + AI recommendations.
  - [x] Streamlined folder structure across `backend/`, `frontend/`, `ai-service/`, `docs/`, `assets/`.
  - [x] Initial file structure committed and pushed to GitHub (`main` branch).
- [x] **Milestone 1: Database Foundation & Models**
  - [x] 11 database migration scripts (10 SmartSpace domain + 1 Sanctum infrastructure).
  - [x] Eloquent models with relationship mappings, normalized bounding box accessors, and hidden raw AI responses.
  - [x] Curated seeders (Roles, 4 root + 9 child categories, 40 dimensioned furniture items, test user accounts, starter room project).
  - [x] Automated PHPUnit test suite with 18 passing assertions.
- [x] **Milestone 2A: Deterministic Geometry Engine (`SpaceCompatibilityService.php`)**
  - [x] Implemented `SpaceCompatibilityService.php` with AABB boundary check, collision, clearance corridors, utilization, and fitness.
  - [x] Created comprehensive unit test suite (`SpaceCompatibilityServiceTest.php`) with 8 passed tests (38 assertions).
- [x] **Milestone 2B: REST API & Sanctum Authentication**
  - [x] Sanctum auth endpoints, furniture catalog filtering with dimensional search, project management with transactional layouts, and favorites.
  - [x] Created `ApiV1Test.php` with 9 tests passing (311 assertions; 22 total passed across application).
- [ ] **Milestone 3: Vue 3 + Three.js Frontend**
  - [ ] Catalog UI, 3D GLB viewer, interactive room canvas, and client HUD (`useSpaceCompatibility.ts`).
- [ ] **Milestone 4: FastAPI AI Microservice & Multi-Provider Layer**
  - [ ] Gemini 2.0 Flash multimodal vision perception with rule-based and mock fallbacks.
- [ ] **Milestone 5: AI-to-Furniture Recommendations**
  - [ ] Geometry-constrained recommendation filtering and style matching.
- [ ] **Milestone 6: System Integration, Evaluation & Defense Preparation**
  - [ ] End-to-end user evaluation and performance benchmarking.

---

## 📝 Changelog

* **2026-09-12 (Milestone 2B Complete)**: Built complete REST API layer (Sanctum authentication, category tree, furniture catalog with physical dimensional boundaries `max_width_cm`, `max_depth_cm`, `max_height_cm`, transactional room project layout sync with automated `SpaceCompatibilityService` certification, on-demand validation endpoint, and favorites toggle). Comprehensive test suite passes 22 tests (367 assertions).
* **2026-09-12 (Milestone 2A Complete)**: Implemented authoritative deterministic spatial compatibility engine in `SpaceCompatibilityService.php` (boundary fit, 3D AABB collision, front/side clearance corridors, space utilization ratio, and room category fitness). Verified with 8 unit tests; total suite reaches 13 passing tests with 56 assertions.
* **2026-09-12 (Milestone 1 Complete)**: Bootstrapped Laravel 11, configured MySQL, ran 11 migrations (10 domain + 1 Sanctum), built Eloquent models with normalized bounding-box accessors, seeded 40 curated furniture pieces across 9 categories with representative dimensions, and verified with 5 PHPUnit tests (18 assertions).
* **2026-09-12 (Commit `b4aca88`)**: Reorganized project documentation, moving full architecture specification to `docs/`.
* **2026-09-12 (Commit `89de1b8`)**: Initial scaffolding of all 113 core directories and empty structure files across backend, frontend, AI microservice, and documentation.
