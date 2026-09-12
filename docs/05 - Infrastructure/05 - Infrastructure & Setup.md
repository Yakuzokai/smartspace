---
title: "05 — Infrastructure & Setup"
tags:
  - smartspace
  - setup
  - environment
  - ports
created: 2026-09-12
---

# 🏗️ 05 — Infrastructure & Setup

Back to [[00 - Home|🏠 Documentation Hub]]

---

## 1. System Requirements & Port Allocation

| Service | Technology | Port | URL |
|:---|:---|:---:|:---|
| **Frontend** | Vite + Vue 3 | `5173` | `http://localhost:5173` |
| **Backend API** | Laravel 11 (PHP 8.3+) | `8000` | `http://localhost:8000` |
| **AI Microservice** | FastAPI (Python 3.11+) | `8001` | `http://localhost:8001` |
| **Database** | MySQL 8.0 (XAMPP) | `3306` | `127.0.0.1:3306` |

---

## 2. Environment Configuration

### Backend (`backend/.env`)
```env
APP_NAME=SmartSpace
APP_URL=http://localhost:8000
FRONTEND_URL=http://localhost:5173

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=smartspace
DB_USERNAME=root
DB_PASSWORD=

SANCTUM_STATEFUL_DOMAINS=localhost:5173
SESSION_DOMAIN=localhost

AI_SERVICE_URL=http://localhost:8001
AI_SERVICE_KEY=smartspace_internal_secret_key
```

### AI Service (`ai-service/.env`)
```env
PORT=8001
HOST=0.0.0.0
AI_PROVIDER=gemini  # gemini | rule_based | mock
GEMINI_API_KEY=your_gemini_api_key_here
SERVICE_API_KEY=smartspace_internal_secret_key
```

---

## 3. Local Execution Guide

### Option A: ⚡ 1-Click Automated Batch Launcher (Recommended)
SmartSpace includes preconfigured Windows batch scripts in the project root:

1. **`start.bat`**:
   - Opens **Port 8000** (Laravel API Gateway).
   - Opens **Port 8001** (FastAPI AI Microservice in Python virtual environment).
   - Opens **Port 5173** (Vue 3 Vite Frontend).
   - Waits 3 seconds and automatically opens your default browser at `http://127.0.0.1:5173/`.
2. **`stop.bat`**:
   - Inspects `netstat` for any active PIDs on ports 8000, 8001, and 5173.
   - Forcefully terminates lingering processes to cleanly free and reset the ports.
3. **`open-firewall-ports.bat`** (Run as Administrator):
   - Adds Windows Defender Firewall inbound rules for TCP ports 5173, 8000, and 8001 for local network and mobile testing.

### Option B: Manual Multi-Terminal Startup
```bash
# 1️⃣ Start MySQL (via XAMPP Control Panel)

# 2️⃣ Quick Database Setup (Import Snapshot or Migrate)
# Option A: Instant import with 40 curated furniture, models, and test users
mysql -u root smartspace < smartspace.sql

# Option B: Clean migration and seed
cd backend
composer install
php artisan key:generate
php artisan migrate:fresh --seed
php artisan storage:link
php artisan serve --port=8000

# 3️⃣ Start Frontend (Terminal 2)
cd frontend
npm install
npm run dev

# 4️⃣ Start AI Microservice (Terminal 3)
cd ai-service
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --port 8001 --reload
```

---

## 4. Local Storage Symlink & Static Assets

Laravel stores uploaded models and images in `backend/storage/app/public/`. Ensure the symlink exists so assets can be resolved:
```bash
cd backend
php artisan storage:link
```
This maps `backend/public/storage` $\rightarrow$ `backend/storage/app/public`.
Vite dev server proxies `/storage` calls directly to port 8000 without CORS configuration headaches.

---

## 5. Gateway Health & Port Telemetry Verification

Verify all subsystems are operational through the centralized gateway endpoint:
```bash
curl -s http://127.0.0.1:8000/api/v1/system/health
```

Expected JSON Response:
* `status`: `"operational"`
* `gateway`: Laravel 11 (`~0.5 ms` response time)
* `database`: MySQL PDO (`~1.1 ms` query latency)
* `spatial_engine`: Deterministic Rotation-Aware AABB Service
* `ai_microservice`: FastAPI internal routing (`~12.4 ms` ping latency)


