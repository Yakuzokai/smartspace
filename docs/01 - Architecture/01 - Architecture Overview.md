---
title: "01 — Architecture Overview"
tags:
  - smartspace
  - architecture
  - capstone
  - high-level
created: 2026-09-12
---

# 🏛️ 01 — Architecture Overview

Back to [[00 - Home|🏠 Documentation Hub]]

---

## 1. System Vision & Central Innovation

SmartSpace is not simply an e-commerce catalog; it is an **AI-assisted spatial planning platform**. The central research contribution is:

> **Generative AI recommendations are strictly constrained by real physical geometry.**

```text
Traditional Recommender System:
  "Based on your profile, here is a popular sofa."

SmartSpace Constraint-Aware System:
  "Based on your room photo, this sofa matches your Scandinavian aesthetic
   AND it fits within your 350×420 cm room
   AND leaves ≥ 75 cm front walking clearance
   AND causes zero collision with your existing coffee table."
```

---

## 2. Three-Tier System Architecture

```mermaid
graph TB
    subgraph "Tier 1: Client Application (Browser)"
        SPA["Vue 3 + TypeScript SPA<br/>Router · Pinia · Tailwind"]
        CANVAS["Three.js 3D Viewport<br/>Interactive Room & Product Viewer"]
        PREVIEW["useSpaceCompatibility.ts<br/>⚡ 60 FPS Client-Side Preview HUD"]
        SPA --- CANVAS
        CANVAS --- PREVIEW
    end

    subgraph "Tier 2: Web API & Business Logic (Web Server)"
        LARAVEL["Laravel 11 REST API<br/>PHP 8.3+ · Sanctum Auth"]
        ENGINE["SpaceCompatibilityService.php<br/>⚖️ Authoritative Deterministic Geometry Engine"]
        LARAVEL --- ENGINE
    end

    subgraph "Tier 3: AI Microservice & Persistence"
        MYSQL[("MySQL 8.0<br/>10 Lean MVP Tables")]
        FASTAPI["Python FastAPI Service<br/>Port 8001 · Async Endpoints"]
        AI_PROVIDERS["AI Provider Layer<br/>Gemini 2.0 Flash · Rule-Based · Mock"]
        FASTAPI --> AI_PROVIDERS
    end

    SPA -->|"REST API (Sanctum Cookie Auth)"| LARAVEL
    LARAVEL -->|"Eloquent ORM"| MYSQL
    LARAVEL -->|"Internal HTTP Proxy (Server-to-Server)"| FASTAPI
```

---

## 3. Key Architectural Principles

1. **Client-Side Preview vs. Backend Authority**:
   - `useSpaceCompatibility.ts` provides instant optimistic feedback at 60 FPS during drag-and-drop.
   - `SpaceCompatibilityService.php` is the authoritative single source of truth that certifies designs upon save.
2. **AI vs. Deterministic Algorithmic Division**:
   - AI handles *perceptual tasks* (detecting style, room type, color palette, aesthetics).
   - Deterministic algorithms handle *spatial calculations* (bounding box overlap, clearances, dimensions, circulation ratio).
3. **Resilient Provider Fallback**:
   - If Gemini is unreachable or rate-limited, the system falls back to rule-based heuristics, and finally to a mock provider, guaranteeing zero downtime during capstone defense demonstrations.
