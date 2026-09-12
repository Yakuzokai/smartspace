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

```bash
# 1️⃣ Start MySQL (via XAMPP Control Panel)

# 2️⃣ Start Backend (Terminal 1)
cd backend
composer install
php artisan key:generate
php artisan migrate --seed
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
