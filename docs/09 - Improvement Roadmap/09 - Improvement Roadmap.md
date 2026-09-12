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

- [x] **Milestone 1: Database Migrations & Eloquent Models**
  - [x] 11 database migration scripts (10 SmartSpace domain + 1 Sanctum infrastructure).
  - [x] Eloquent models with relationship methods, normalized bounding box accessors, and hidden raw AI responses.
  - [x] Curated seeders with 40 representative furniture items across 9 categories.
  - [x] Automated PHPUnit test suite (5 passed, 18 assertions).

- [x] **Milestone 2A: Deterministic Geometry Engine (`SpaceCompatibilityService.php`)**
  - [x] AABB boundary containment validation math (Three.js center-origin & corner-origin).
  - [x] 3D/2D bounding box collision detection between placed items.
  - [x] Front/side clearance scoring algorithm ($c_{\text{front}} \ge 75\text{ cm}, c_{\text{side}} \ge 60\text{ cm}$).
  - [x] Space utilization ratio ($R_{\text{walk}} \ge 0.40$) and room-type category appropriateness.
  - [x] Comprehensive PHPUnit test suite (8 passed, 38 assertions; 13 total passed across suite).

- [x] **Milestone 2B: REST API & Sanctum Authentication**
  - [x] Sanctum auth endpoints (register, login, logout, profile).
  - [x] Furniture catalog API with pagination, category, style, and physical dimensional filters (`max_width_cm`, `max_depth_cm`, `max_height_cm`).
  - [x] Room projects API with transactional 3D layout updates and automatic `SpaceCompatibilityService` certification.
  - [x] Protected project spatial validation endpoint (`POST /room-projects/{id}/validate`).
  - [x] Favorites API with instant toggle.
  - [x] Automated PHPUnit API Feature test suite (9 passed, 311 assertions; 22 total passed across application).

- [ ] **Milestone 3: Vue 3 + Three.js Frontend**
  - [ ] Furniture catalog grid, search, and filter UI.
  - [ ] Single item Three.js OrbitControls GLB viewer with dimension annotations.
  - [ ] Interactive 3D Room Planner with drag, drop, rotation, and wall constraints.
  - [ ] Real-time client HUD (`useSpaceCompatibility.ts`) for optimistic 60 FPS feedback.
  - [ ] Project persistence (Save/Load design).

- [ ] **Milestone 4: FastAPI AI Microservice & Multi-Provider Layer**
  - [ ] Vision room photo analysis using Gemini 2.0 Flash.
  - [ ] Rule-based and mock fallback providers for zero downtime.
  - [ ] Laravel `AIServiceClient.php` proxy integration.

- [ ] **Milestone 5: AI-to-Furniture Recommendations**
  - [ ] Geometry-constrained recommendation filtering.
  - [ ] Room style and color harmony matching.
  - [ ] Curated room packages.

- [ ] **Milestone 6: System Integration & Capstone Defense Prep**
  - [ ] End-to-end integration and user evaluation testing.
  - [ ] Performance benchmarks (Three.js FPS, API latency, fallback reliability).

---

## 2. Deferred Backlog (Post-Capstone Phase 2)

* Multi-stage e-commerce checkout and payment gateway integrations.
* Physical warehouse inventory logistics.
* Executive sales analytics and enterprise audit trails.
* Multi-user collaborative simultaneous room editing.
