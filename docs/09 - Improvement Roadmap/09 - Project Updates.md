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
- [x] **Milestone 3: Vue 3 + Three.js Frontend Foundation & Catalog**
  - [x] Implemented Vue 3 + TypeScript SPA adhering strictly to Figma visual identity (Deep Forest Green `#173F35`, Warm Beige `#D8B98A`, Cream `#F7F4EE`).
  - [x] Built responsive catalog grid with live keyword search, category drawer, price sorting, and physical dimensional filters (`max_width_cm`, etc.).
  - [x] User authentication (Login, Register, Logout) via Laravel Sanctum cookies/tokens with robust session deserialization.
  - [x] Favorites management with instant Pinia state synchronization.

- [x] **Milestone 4: Interactive Three.js 3D Furniture Viewer**
  - [x] Dedicated 3D product inspection studio on `/furniture/:id` with dual-mode toggle (Photo Gallery vs 3D Model).
  - [x] Reusable `useModelLoader.ts` with in-memory caching and Google Draco decompression.
  - [x] Built dimension-certified architectural procedural fallback for un-modeled catalog pieces.
  - [x] OrbitControls with rotation, pan, zoom damping, and auto-turntable.
  - [x] 4 camera presets (Front, Side, Top, 3/4) and 3 lighting presets (Showroom, Daylight, Golden Hour).
  - [x] Authoritative HUD displaying physical dimensions ($W \times D \times H$ in cm), wireframe bounding box, and locked `scale = 1.000`.

- [x] **Milestone 5: Interactive 3D Room Planner & Deterministic Certification**
  - [x] Parametric room scene builder (`useRoomScene.ts`) with floor grid, baseboards, and cutaway south wall for unobstructed camera orbiting.
  - [x] Dual camera modes: 3D Orbit Perspective and 2D Top-Down Architectural Blueprint.
  - [x] 4 architectural room lighting modes: Showroom Studio, Daylight, Golden Hour, Evening Ambient.
  - [x] Catalog drawer (`FurniturePickerSidebar.vue`) with category filters and instant "+ Add to Room".
  - [x] Interactive manipulation (`useFurniturePlacement.ts`): floor-plane raycast dragging with **free movement** (no silent boundary snapping).
  - [x] Trigonometric rotation-aware AABB calculations ($w_{\text{rot}} = |w\cos\theta| + |d\sin\theta|$, $d_{\text{rot}} = |w\sin\theta| + |d\cos\theta|$).
  - [x] Real-time client preview feedback: `status = 'out_of_bounds'` triggers red bounding box and provides an explicit **"⎋ Snap Inside Room"** action.
  - [x] Multiple instances supported via unique client `uuid: string`.
  - [x] Strict architectural boundary: Client computes preview states only; authoritative 5-factor score ($30+25+25+10+10=100$) is certified strictly by Laravel's `SpaceCompatibilityService` upon "Save & Certify" (`PUT /api/v1/room-projects/{id}/layout`).
  - [x] Decoupled room budget planner (Target, Selected, Remaining).

- [x] **Milestone 6: FastAPI AI Microservice & Multi-Provider Layer**
  - [x] Gemini 2.0 Flash multimodal vision perception for room photo analysis (room type, style, color palette, clutter).
  - [x] Rule-based (heuristic histogram) and mock demonstration fallback providers guaranteeing zero defense downtime.
  - [x] Laravel `AIServiceClient.php` proxy gateway with timeout handling and `room_analyses` table persistence.
  - [x] Architectural separation invariant: AI scores aesthetic affinity; Laravel strictly enforces physical room bounding constraints.
  - [x] Interactive Vue 3 `AiAssistantModal.vue` integrated into the 3D Room Planner, preserving M5's uncertified placement preview and explicit Save & Certify workflow.

- [x] **Milestone 7: System Integration, Performance Benchmarking & Capstone Defense Prep**
  - [x] Strict Gateway Telemetry: Implemented `GET /api/v1/system/health` aggregating Laravel, Database, Spatial Engine, and FastAPI microservice metrics. Frontend communicates exclusively with Laravel; FastAPI (:8001) is strictly internal.
  - [x] Empirical Spatial Benchmarking: Executed 100-iteration stress testing via `php artisan smartspace:benchmark` across $N=5, 10, 20, 40$ furniture items. P95 latency reached $\le 0.37\text{ ms}$, comfortably surpassing the $< 10.0\text{ ms}$ academic budget.
  - [x] Defense Demonstration Scenarios: Seeded 3 calibrated scenarios dynamically evaluated by `SpaceCompatibilityService`:
    - Scenario A: High Compliance Living Room ($100/100$ certified score)
    - Scenario B: Conflict & Recovery Demo ($29/100$, Collision: 0/25, Boundary: 0/30)
    - Scenario C: AI Vision Sandbox (Uncertified blank state for live photo analysis)
  - [x] Evaluator Telemetry Modal (`SystemHealthModal.vue`) and Scenario Switcher in `RoomPlannerPage.vue`.
  - [x] Comprehensive Capstone Defense Guide & Technical Dossier ([[10 - Capstone Defense Guide/10 - Capstone Defense Guide|10 - Capstone Defense Guide]]).
  - [x] Production build validation (`npm run build`, `vue-tsc -b`, 0 errors).
  - [x] Complete capstone architecture locked and frozen.

---

## 📝 Changelog

* **2026-09-12 (Milestone 7 Complete, Benchmarked & Architecture Frozen)**: Finalized Capstone Milestone 7. Implemented gateway health aggregator endpoint `GET /api/v1/system/health` adhering strictly to the `Vue ➔ Laravel ➔ FastAPI` topology. Built and ran empirical benchmark harness `php artisan smartspace:benchmark` over 100 iterations (P95 latency: $N=5 \rightarrow 0.032\text{ ms}$, $N=10 \rightarrow 0.083\text{ ms}$, $N=20 \rightarrow 0.143\text{ ms}$, $N=40 \rightarrow 0.374\text{ ms}$, passing the $< 10.0\text{ ms}$ SLA across all scales). Seeded 3 calibrated defense scenarios with real geometric scores calculated by `SpaceCompatibilityService`. Built `SystemHealthModal.vue` with live client WebGL/Three.js FPS, draw calls, GPU info, and benchmark tables. Authored comprehensive Capstone Defense Guide (`docs/10 - Capstone Defense Guide/10 - Capstone Defense Guide.md`) with mathematical proofs, 10-minute defense script, and examiner Q&A. Verified 0 TypeScript errors and successful production build.
* **2026-09-12 (Milestone 6 Complete & Verified)**: Built full Python FastAPI AI microservice (port 8001) with Gemini 2.0 Flash, Pillow-based rule heuristic provider, and offline mock demonstration provider. Created Laravel `AIServiceClient` gateway and `AIController` with `room_analyses` caching and geometry-constrained filtering. Built Vue 3 `AiAssistantModal.vue` in the 3D Room Planner with photo drag-and-drop, dominant palette swatches, and 1-click addition to the 3D canvas in uncertified preview state. Verified with passing pytest suite (3/3 passed), passing Laravel AI feature tests (3/3 passed, 19 assertions), and clean Vite production build.
* **2026-09-12 (Milestone 4 Fullscreen Studio Fix & Production Build)**: Resolved canvas-only fullscreen regression in `Product3DViewer.vue`. Fixed root container targeting, scoped `:fullscreen` gradient background styling to eliminate browser black void, wired `fullscreenchange` listener for seamless `Esc` key synchronization, and kept all HUD and studio controls inside the fullscreen subtree. Verified with clean TypeScript typecheck (`vue-tsc -b`) and successful Vite production bundle build (`npm run build`).
* **2026-09-12 (Database Dump & Git Backup)**: Exported complete live MariaDB/MySQL database to `smartspace.sql` (40 furniture records, 42 image records, 40 model records, 13 categories, 3 room projects, 11 placements, 7 users). Committed and pushed to GitHub `main`.
* **2026-09-12 (Photo Gallery & Transparent Studio Rendering)**: Configured Vite proxy for `/storage` (port 8000) and updated `FurnitureImage.vue` to relative paths to eliminate CORS issues. Automated Blender studio camera rendering at $4.2\text{m}$ ($42\text{mm}$ lens) with transparent alpha background, generating 3 balanced showroom photos for `SOFA-001` with an interactive thumbnail strip.
* **2026-09-12 (Blender OBJ-to-Draco GLB Conversion Pipeline)**: Successfully converted real-world couch asset (`couch.obj` + PBR fabric textures) into an optimized, Draco-compressed `SOFA-001.glb` (5.2 MB, 138k polygons) using headless Blender 5.2, replacing procedural fallback in both the 3D Product Viewer and 3D Room Planner.
* **2026-09-12 (Milestone 5 Locked & Verified)**: Finalized 3D Room Planner specification and implementation. Locked free floor dragging, rotation-aware trigonometric AABB calculations, out-of-bounds explicit snap-back, and `PlacementStatus` types in `project.ts`. Verified 100/100 certified engine compatibility.
* **2026-09-12 (Milestone 4 Complete)**: Implemented Three.js 3D Furniture Viewer with Draco GLB loading, dimension-certified procedural fallbacks, OrbitControls, 4 camera presets, 3 lighting presets, bounding box HUD, and locked `scale = 1.000`.
* **2026-09-12 (Milestone 3 Complete)**: Built complete Vue 3 + TypeScript frontend matching Figma design tokens (Forest Green, Warm Beige, Cream, Off-White), responsive catalog, search, favorites, and Sanctum auth.
* **2026-09-12 (Milestone 2B Complete)**: Built complete REST API layer (Sanctum authentication, category tree, furniture catalog with physical dimensional boundaries, transactional room project layout sync with automated `SpaceCompatibilityService` certification, validation endpoint, and favorites toggle). Comprehensive test suite passes 22 tests (367 assertions).
* **2026-09-12 (Milestone 2A Complete)**: Implemented authoritative deterministic spatial compatibility engine in `SpaceCompatibilityService.php`. Verified with 8 unit tests (56 assertions).
* **2026-09-12 (Milestone 1 Complete)**: Bootstrapped Laravel 11, configured MySQL, ran 11 migrations, built Eloquent models, seeded 40 curated furniture pieces across 9 categories.
* **2026-09-12 (Commit `b4aca88`)**: Reorganized project documentation, moving full architecture specification to `docs/`.
* **2026-09-12 (Commit `89de1b8`)**: Initial scaffolding of all 113 core directories and empty structure files across backend, frontend, AI microservice, and documentation.
