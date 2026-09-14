---
title: "Tech Stack & Languages"
aliases:
  - Tech Stack
  - Languages Used
  - System Technologies
tags:
  - smartspace
  - tech-stack
  - languages
  - architecture
  - reference
created: 2026-09-15
version: "1.0.0"
---

# 🧰 Tech Stack & Languages

> Documents **what is currently built and running** in SmartSpace — the programming languages, frameworks, libraries, and tools used across all three tiers of the system.

---

## 🗺️ System Architecture Overview

SmartSpace is a **3-tier architecture** using three different programming languages across three separate services:

```
Browser
  └── TypeScript / Vue 3 (Frontend SPA)
        │
        ▼ HTTP (Axios → REST API)
  Laravel 11 (PHP Backend)
        │
        ├── MySQL (SQL Database)
        │
        └── FastAPI (Python AI Microservice)
               │
               ▼ HTTP
         Google Gemini Vision API
```

---

## 📝 Programming Languages at a Glance

| Language | Where | What It Does |
|:---|:---|:---|
| **TypeScript** | Frontend | All Vue components, Pinia stores, router, API service calls |
| **HTML** (Vue SFC) | Frontend | Component templates inside `.vue` single-file components |
| **CSS** (via Tailwind) | Frontend | All styling — utility classes, custom design tokens, animations |
| **PHP 8.2** | Backend | Laravel controllers, models, migrations, seeders, API logic |
| **Python 3.11+** | AI Service | FastAPI endpoints, Gemini vision, 3-level AI fallback chain |
| **SQL (MySQL)** | Database | 10-table relational schema, migrations, seeded furniture data |
| **GLSL / WebGL** | Frontend (3D) | Shader rendering via Three.js for the 3D Room Planner |
| **Batch Script (.bat)** | Infrastructure | `start.bat`, `stop.bat`, `sync-models.bat` — service orchestration |
| **Markdown** | Docs | This entire Obsidian documentation vault |
| **JSON / YAML** | Config | `package.json`, `composer.json`, `.env`, `tailwind.config.js` |

---

## 🖥️ Frontend — `frontend/`

**Language:** TypeScript + HTML (Vue SFC) + CSS (Tailwind)

| Library / Tool | Version | What It Does |
|:---|:---|:---|
| **Vue 3** | `^3.5.13` | UI framework — Composition API, `<script setup>`, reactivity |
| **TypeScript** | `~5.7.2` | Strict typing on all components, stores, and API responses |
| **Vite** | `^6.1.0` | Dev server + production bundler with Hot Module Replacement |
| **Vue Router 4** | `^4.5.0` | Client-side routing (`/`, `/catalog`, `/product/:id`, `/projects`, etc.) |
| **Pinia** | `^2.3.1` | Global state — `auth`, `catalog`, `favorites`, `projects` stores |
| **Three.js** | `^0.186.0` | 3D Room Planner WebGL canvas + GLB furniture model rendering |
| **Tailwind CSS** | `^3.4.17` | Utility-first CSS with custom SmartSpace design token extensions |
| **Axios** | `^1.7.9` | HTTP client for all calls to the Laravel REST API |
| **Bootstrap Icons** | `^1.13.1` | Icon set used throughout the UI (`bi-heart`, `bi-box`, `bi-bag`, etc.) |
| **Lucide Vue Next** | `^0.475.0` | Secondary icon library |
| **PostCSS** | `^8.5.2` | CSS processing pipeline (used by Tailwind) |

### Design System Tokens

| Token | Value | Used For |
|:---|:---|:---|
| `forest` | `#173F35` | Primary brand color, buttons, headings, links |
| `dark-green` | `#0F2F28` | Hover state for forest |
| `warm-beige` | `#D8B98A` | Accent — prices, badges, highlights |
| `cream` | `#F7F4EE` | Card backgrounds, surfaces |
| `off-white` | `#FCFCFA` | Page background |
| `charcoal` | `#252A27` | Primary body text |
| `muted-gray` | `#737A76` | Secondary text, labels |
| `light-border` | `#E5E3DD` | Card borders, dividers |

---

## ⚙️ Backend — `backend/`

**Language:** PHP 8.2

| Library / Tool | Version | What It Does |
|:---|:---|:---|
| **Laravel** | `^11.0` | REST API framework — routing, controllers, Eloquent ORM, migrations |
| **Laravel Sanctum** | `^4.0` | Cookie-based SPA auth (CSRF tokens + session cookies) |
| **MySQL** (via XAMPP) | — | Relational database — furniture, users, rooms, favorites (10 tables) |
| **Laravel Tinker** | `^2.9` | REPL shell for database interaction during development |
| **Faker PHP** | `^1.23` | Generates realistic seed data for the 40 curated furniture items |
| **PHPUnit** | `^10.5` | Backend unit and feature test suite |
| **Laravel Pint** | `^1.13` | PHP code style formatter |

### Current API Endpoints

| Method | Endpoint | Description |
|:---|:---|:---|
| `GET` | `/api/furniture` | Paginated, filterable furniture catalog |
| `GET` | `/api/furniture/{id}` | Single product with full specs + images |
| `GET` | `/api/categories` | Room category tree with subcategories |
| `GET` | `/api/styles` | Furniture style list |
| `POST` | `/api/auth/login` | User login (Sanctum session) |
| `POST` | `/api/auth/register` | New user registration |
| `POST` | `/api/auth/logout` | Session logout |
| `GET` | `/api/auth/user` | Current authenticated user |
| `GET/POST/DELETE` | `/api/favorites` | Wishlist management |
| `GET/POST` | `/api/rooms` | 3D room project CRUD |
| `GET` | `/api/system/health` | System telemetry + service health |

---

## 🤖 AI Microservice — `ai-service/`

**Language:** Python 3.11+

| Library / Tool | Version | What It Does |
|:---|:---|:---|
| **FastAPI** | `>=0.115.0` | Async REST API framework |
| **Uvicorn** | `>=0.32.0` | ASGI server that runs the FastAPI app |
| **Pydantic v2** | `>=2.9.0` | Request/response validation and data serialization |
| **Pydantic Settings** | `>=2.5.0` | Environment config management |
| **Google GenAI SDK** | `>=1.0.0` | Calls the Gemini Vision API to analyze room photos |
| **Pillow** | `>=11.0.0` | Preprocesses uploaded images before AI analysis |
| **HTTPX** | `>=0.28.0` | Async HTTP client for internal service communication |
| **python-dotenv** | `>=1.0.1` | Loads `.env` configuration |
| **pytest** | `>=8.3.0` | AI service test suite |

### AI Fallback Chain

```
1. Gemini Vision (Google AI)       ← primary
       │ (if unavailable)
       ▼
2. Rule-Based Heuristics           ← fallback
       │ (if error)
       ▼
3. Mock Response                   ← last resort (always returns valid data)
```

---

## 🗄️ Database — MySQL

**Language:** SQL

| Table | Description |
|:---|:---|
| `users` | Registered accounts |
| `furniture` | 40 curated 3D-modeled furniture items |
| `categories` | Room categories (Living Room, Bedroom, etc.) with subcategories |
| `furniture_images` | Product image gallery (multiple per item) |
| `furniture_availability` | Stock status and quantity |
| `styles` | Furniture style tags (Modern, Scandinavian, Industrial, etc.) |
| `favorites` | User wishlist (pivot: user ↔ furniture) |
| `rooms` | Saved 3D room planner projects |
| `room_furniture` | Furniture placements inside a room |
| `personal_access_tokens` | Laravel Sanctum token table |

---

## 🏗️ Infrastructure & Dev Environment

| Tool | Purpose |
|:---|:---|
| **XAMPP** | Runs local Apache web server + MySQL database |
| **`start.bat`** | Launches all 3 services simultaneously (Vite + Laravel + FastAPI) |
| **`stop.bat`** | Gracefully stops all running services |
| **`sync-models.bat`** | Syncs 3D GLB model files into the public assets directory |
| **`.env`** | Per-service environment config (DB credentials, API keys, ports) |
| **Port 5173** | Vue 3 frontend (Vite dev server) |
| **Port 8000** | Laravel REST API (`php artisan serve`) |
| **Port 8001** | FastAPI AI microservice (`uvicorn`) |
| **Obsidian** | Markdown documentation vault (this docs folder) |

---

## 🔗 Related Documentation

- [[09 - Improvement Roadmap/09 - E-Commerce UI Upgrade Plan|09 - E-Commerce UI Upgrade Plan]]
- [[01 - Architecture/01 - Architecture Overview|01 - Architecture Overview]]
- [[07 - API/07 - API Specification & Contracts|07 - API Specification]]
- [[04 - Data/04 - Data Architecture & ERD|04 - Data Architecture & ERD]]
- [[02 - Services/02 - Services Overview|02 - Services Overview]]
