---
title: "03 — Messaging & Protocols"
tags:
  - smartspace
  - messaging
  - api-protocols
  - network
created: 2026-09-12
---

# 📨 03 — Messaging & Communication

Back to [[00 - Home|🏠 Documentation Hub]]

---

## 1. Network Topology & Communication Paths

The browser **never** speaks to the AI microservice or the MySQL database directly. All traffic is brokered through the Laravel API:

```
[Browser Client] 
       │
       │ HTTP / HTTPS (REST + JSON, Cookie Auth)
       ▼
[Laravel 11 API Gateway]
       ├──▶ [MySQL Database] (Internal PDO Socket / Port 3306)
       └──▶ [FastAPI AI Microservice] (Internal HTTP / Port 8001)
                    └──▶ [Gemini API] (External HTTPS over TLS)
```

---

## 2. Client-to-Backend Protocol (Vue 3 $\leftrightarrow$ Laravel 11)

* **Transport**: HTTPS (HTTP/2 in production, HTTP/1.1 local).
* **Authentication**: **Laravel Sanctum Cookie-Based SPA Auth**.
  * Handshake: `GET /sanctum/csrf-cookie` $\rightarrow$ sets `XSRF-TOKEN` cookie.
  * Subsequent requests send the cookie + `X-XSRF-TOKEN` header.
* **Payload Format**: Standardized JSON envelopes:
  ```json
  {
    "success": true,
    "data": { ... },
    "message": "Operation successful",
    "meta": { "timestamp": 1726108800 }
  }
  ```

---

## 3. Backend-to-AI Protocol (Laravel 11 $\leftrightarrow$ Python FastAPI)

* **Implementation**: Managed by `AIServiceClient.php` using Laravel's `Illuminate\Support\Facades\Http`.
* **Transport**: Local HTTP (`http://127.0.0.1:8001`) with configurable timeout (`AI_SERVICE_TIMEOUT=30`).
* **Header Authorization**: Internal secret header (`X-Service-Key: ...`) to prevent unauthenticated direct queries.
* **Photo Upload Proxy**:
  ```php
  $response = Http::timeout(30)
      ->withHeaders(['X-Service-Key' => config('services.ai.key')])
      ->attach('image', file_get_contents($imagePath), basename($imagePath))
      ->post(config('services.ai.url') . '/api/v1/analyze-room', [
          'room_type_hint' => $hint,
      ]);
  ```
* **Failure Handling**: If FastAPI is down or times out, Laravel traps the `ConnectionException` and gracefully degrades by returning fallback mock/rule-based metadata with `_mock: true`.
