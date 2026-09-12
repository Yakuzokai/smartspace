---
title: "09 — Improvement Roadmap & Milestones"
tags:
  - smartspace
  - roadmap
  - milestones
  - phases
created: 2026-09-12
---

# 🚀 09 — Improvement Roadmap & Milestones

Back to [[00 - Home|🏠 Documentation Hub]]  
See also: [[09 - Improvement Roadmap/09 - Project Updates|📋 Recent Updates Log]]

---

## 1. Active Capstone Milestones (Core MVP)

- [x] **Milestone 0: Baseline Lock & Scaffolding**
  - [x] Refined project thesis to spatial geometry + AI recommendations.
  - [x] Created clean numbered documentation structure in Obsidian.
  - [x] Initial file structure scaffolded and committed to GitHub `main`.

- [ ] **Milestone 1: Database Migrations & Eloquent Models**
  - [ ] Write all 10 lean migrations.
  - [ ] Eloquent models with relationship methods and attribute casting.
  - [ ] Realistic furniture seeders with accurate dimensional data.

- [ ] **Milestone 2: Deterministic Geometry Engine (`SpaceCompatibilityService.php`)**
  - [ ] AABB boundary containment validation math.
  - [ ] 3D bounding box collision detection between items.
  - [ ] Front/side clearance scoring algorithm.
  - [ ] Unit test suite for edge-case spatial arrangements.

- [ ] **Milestone 3: FastAPI Microservice & Multi-Provider Layer**
  - [ ] Vision analysis route using Gemini 2.0 Flash multimodal API.
  - [ ] Rule-based and mock fallback providers.
  - [ ] Laravel `AIServiceClient.php` gateway and response caching.

- [ ] **Milestone 4: Frontend Catalog & 3D Product Inspector**
  - [ ] Pinia stores for user auth and catalog search.
  - [ ] Single item Three.js OrbitControls GLB viewer with dimension overlay.

- [ ] **Milestone 5: Three.js Interactive 3D Room Planner**
  - [ ] Configurable room boundary rendering (walls, floor, scale grid).
  - [ ] Drag-and-drop raycast placement, rotation, and wall snapping.
  - [ ] Client HUD (`useSpaceCompatibility.ts`) for real-time 60 FPS feedback.
  - [ ] Persistent save/load project workflow.

- [ ] **Milestone 6: System Integration & Capstone Defense Prep**
  - [ ] End-to-end user evaluation tests.
  - [ ] Performance benchmarks (Three.js FPS, API latency, fallback trigger verification).

---

## 2. Deferred Backlog (Post-Capstone Phase 2)

* Multi-stage e-commerce checkout and payment gateway integrations.
* Physical warehouse inventory logistics.
* Executive sales analytics and enterprise audit trails.
* Multi-user collaborative simultaneous room editing.
