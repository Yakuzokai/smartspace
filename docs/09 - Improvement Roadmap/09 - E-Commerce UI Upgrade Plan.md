---
title: "E-Commerce UI Upgrade Plan"
aliases:
  - E-Commerce Upgrade
  - Cart & Checkout Plan
  - Furniture Shop Upgrade
tags:
  - smartspace
  - ecommerce
  - ui
  - roadmap
  - cart
  - checkout
created: 2026-09-15
version: "1.0.0"
status: "Planned"
---

# 🛒 E-Commerce UI Upgrade Plan

> **Goal:**  
> Layer a full furniture e-commerce shopping experience on top of the existing SmartSpace spatial planning platform — adding cart, checkout, and order flow — without removing any AI/3D planner features. The room planner becomes a **premium differentiator** that sets SmartSpace apart from generic furniture shops.

---

## 🧰 Current System — Languages & Tech Stack

> This section documents **what is already built and running** in SmartSpace today, with no e-commerce changes applied yet.

SmartSpace is a **3-tier architecture** using three different languages across three separate services:

```
Browser (TypeScript/Vue) ──► Laravel API (PHP) ──► MySQL Database
                                    │
                                    └──► FastAPI AI Service (Python) ──► Gemini API
```

---

### 📝 Programming Languages Used

| Language | Tier | Purpose |
|:---|:---|:---|
| **TypeScript** | Frontend | All Vue components, Pinia stores, router, API services |
| **HTML** (Vue Templates) | Frontend | Component markup inside `.vue` single-file components |
| **CSS** (via Tailwind) | Frontend | All styling — utility classes, custom design tokens |
| **PHP 8.2** | Backend | Laravel controllers, models, migrations, seeders, API logic |
| **Python 3.11+** | AI Service | FastAPI endpoints, Gemini vision integration, fallback logic |
| **SQL (MySQL)** | Database | 10-table schema, migrations, seed data |
| **Batch Script (.bat)** | Infrastructure | `start.bat`, `stop.bat`, `sync-models.bat` — service orchestration |
| **Markdown** | Docs | This entire Obsidian documentation vault |

---

### 🖥️ Frontend — `frontend/` (TypeScript + Vue)

| Library / Tool | Version | What It Does |
|:---|:---|:---|
| **Vue 3** | `^3.5.13` | UI framework — Composition API, `<script setup>`, reactivity |
| **TypeScript** | `~5.7.2` | Strict typing on all components, stores, and API responses |
| **Vite** | `^6.1.0` | Build tool and dev server with Hot Module Replacement |
| **Vue Router 4** | `^4.5.0` | Page routing (`/`, `/catalog`, `/product/:id`, `/projects`, etc.) |
| **Pinia** | `^2.3.1` | Global state — `auth`, `catalog`, `favorites`, `projects` stores |
| **Three.js** | `^0.186.0` | 3D Room Planner WebGL canvas + GLB furniture model rendering |
| **Tailwind CSS** | `^3.4.17` | Utility-first CSS with custom SmartSpace design tokens |
| **Axios** | `^1.7.9` | HTTP client for all calls to the Laravel REST API |
| **Bootstrap Icons** | `^1.13.1` | Icon set used throughout UI (`bi-heart`, `bi-box`, etc.) |
| **Lucide Vue Next** | `^0.475.0` | Secondary icon library |

**Design Tokens (current brand palette):**
- `forest` → `#173F35` — primary brand, buttons, headings
- `warm-beige` → `#D8B98A` — accent, price, highlights
- `cream` → `#F7F4EE` — card backgrounds, surfaces
- `charcoal` → `#252A27` — body text
- `muted-gray` → `#737A76` — secondary text, labels

---

### ⚙️ Backend — `backend/` (PHP + Laravel)

| Library / Tool | Version | What It Does |
|:---|:---|:---|
| **PHP** | `^8.2` | Server runtime |
| **Laravel** | `^11.0` | REST API — routing, controllers, Eloquent ORM, migrations |
| **Laravel Sanctum** | `^4.0` | Cookie-based SPA auth (CSRF tokens + session cookies) |
| **MySQL** (via XAMPP) | — | Relational database — stores furniture, users, rooms, favorites |
| **Faker PHP** | `^1.23` | Generates realistic seed data for the 40 furniture items |
| **PHPUnit** | `^10.5` | Backend unit and feature test suite |

**Current live API endpoints:**
- `GET /api/furniture` — paginated, filterable furniture catalog
- `GET /api/furniture/{id}` — single product with full specs
- `GET /api/categories` — room category tree
- `POST /api/auth/login` · `register` · `logout`
- `GET/POST/DELETE /api/favorites` — wishlist management
- `POST/GET /api/rooms` — 3D room project CRUD
- `GET /api/system/health` — service health telemetry

---

### 🤖 AI Microservice — `ai-service/` (Python + FastAPI)

| Library / Tool | Version | What It Does |
|:---|:---|:---|
| **Python** | `3.11+` | Runtime |
| **FastAPI** | `>=0.115.0` | Async REST API framework |
| **Uvicorn** | `>=0.32.0` | ASGI server that runs FastAPI |
| **Pydantic v2** | `>=2.9.0` | Request/response validation and serialization |
| **Google GenAI SDK** | `>=1.0.0` | Calls Gemini Vision API to analyze room photos |
| **Pillow** | `>=11.0.0` | Preprocesses uploaded room images before AI analysis |
| **HTTPX** | `>=0.28.0` | Async HTTP client for internal service calls |

**3-level AI fallback chain:**
1. `Gemini Vision` — primary (Google AI)
2. `Rule-Based Heuristics` — fallback if Gemini is unavailable
3. `Mock Response` — last resort, always returns a valid response

---

### 🏗️ Infrastructure & Dev Environment

| Tool | Purpose |
|:---|:---|
| **XAMPP** | Runs local Apache web server + MySQL |
| **`start.bat`** | Launches all 3 services (Vite + Laravel + FastAPI) |
| **`stop.bat`** | Gracefully stops all services |
| **`sync-models.bat`** | Syncs 3D GLB model files to the public directory |
| **Port 5173** | Vite dev server (Vue frontend) |
| **Port 8000** | Laravel API (`php artisan serve`) |
| **Port 8001** | FastAPI AI microservice (`uvicorn`) |
| **`.obsidian/`** | Obsidian vault config for this docs folder |

---

### 🆕 E-Commerce Additions (New to Stack)

These are **no new dependencies required** — all built using existing stack:

| What | How |
|:---|:---|
| Cart persistence | `localStorage` via native browser API (no new package) |
| Cart state | New Pinia store (`stores/cart.ts`) |
| Checkout state | New Pinia store (`stores/checkout.ts`) |
| Toast notifications | CSS + Vue `v-if` transitions (no extra library) |
| Multi-step form | Vue reactive state machine (no router change per step) |

---

## 📋 Full Project Audit

### ✅ What Already Exists (Keep As-Is)

| Feature | File(s) | Notes |
|:---|:---|:---|
| Product Catalog | `CatalogPage.vue`, `FurnitureCard.vue` | Filter sidebar, sort bar, pagination |
| Product Detail | `ProductDetailPage.vue` | Image gallery, 3D GLB viewer, specs |
| Auth Flow | `LoginPage.vue`, `RegisterPage.vue` | Sanctum-based, fully working |
| Favorites / Wishlist | `FavoritesPage.vue`, `stores/favorites.ts` | Heart button on cards |
| Room Planner | `RoomPlannerPage.vue` | Three.js canvas, keep as feature |
| Brand System | `index.css`, `tailwind.config.js` | Forest green + warm-beige palette |
| Laravel API | `backend/` | REST endpoints, Sanctum, 10-table DB |

### ⚠️ What Needs to Be Upgraded (UI Changes)

| Component | Current State | E-Commerce Change |
|:---|:---|:---|
| `AppNavbar.vue` | No cart icon | Add cart bag icon + badge counter |
| `AppNavbar.vue` | Subtitle: "Spatial Planning" | Change to: "Furniture & Design" |
| `AppNavbar.vue` | Nav: "Catalog", "Room Projects" | Rename: "Shop", "Room Planner" |
| `FurnitureCard.vue` | "View Specs →" text link only | Add **Add to Cart** button + hover quick-add overlay |
| `ProductDetailPage.vue` | Only "Save to Favorites" action | Add **Add to Cart** + **Buy Now** + qty stepper |
| `HomePage.vue` | Spatial planning-first hero | Add promo strip, e-commerce trust badges, shop CTA |
| `AppFooter.vue` | Academic capstone credits & milestones | Real store footer: links, payment icons, newsletter |

### 🆕 What Needs to Be Created (New Files)

| File | Type | Purpose |
|:---|:---|:---|
| `stores/cart.ts` | Pinia Store | Cart state, localStorage persist, add/remove/update |
| `stores/checkout.ts` | Pinia Store | Checkout form state, order submission |
| `components/cart/CartDrawer.vue` | Component | Slide-in cart sidebar triggered by nav icon |
| `pages/CartPage.vue` | Page | Full `/cart` route with line items + summary |
| `pages/CheckoutPage.vue` | Page | Multi-step checkout: Shipping → Payment → Review |
| `pages/OrderConfirmationPage.vue` | Page | Success page post-order |

---

## 🗺️ Implementation Phases

### Phase 1 — Cart Store + Navbar Icon
**Scope:** Foundation layer. No UI visible yet without the drawer.

```
stores/cart.ts                  [NEW]
components/common/AppNavbar.vue [MODIFY]
```

**Cart Store (`stores/cart.ts`) — Features:**
- `items: CartItem[]` — array of cart line items
- `addItem(furniture, qty)` — adds or increments existing
- `removeItem(id)` — removes by furniture ID
- `updateQuantity(id, qty)` — sets quantity (0 = remove)
- `clearCart()` — empties cart
- `count` — total item count (sum of all quantities)
- `subtotal` — total price
- `isInCart(id)` — boolean check
- `isDrawerOpen` — controls cart drawer visibility
- Persisted to `localStorage` under key `smartspace_cart`

**Navbar Changes:**
- Add `🛍 cart` icon between Favorites and User with animated badge
- Change tagline from `"Spatial Planning"` → `"Furniture & Design"`
- Rename nav: `Catalog` → `Shop`, `Room Projects` → `Room Planner`
- Mobile drawer: add Cart shortcut

---

### Phase 2 — Add to Cart on Cards & Detail Page
**Scope:** The primary purchase trigger points.

```
components/catalog/FurnitureCard.vue  [MODIFY]
pages/ProductDetailPage.vue           [MODIFY]
```

**FurnitureCard Changes:**
- **Hover overlay** — on mouse-over, a semi-transparent overlay fades in with a centered "Add to Cart" button
- **Bottom action bar** — replace "View Specs →" text with a compact `[Add]` button that shows `[In Cart ✓]` when already in cart
- Out-of-stock items show disabled state

**ProductDetailPage Changes:**
- **Quantity stepper** (`-` / number / `+`) above action buttons
- **Primary CTA:** `🛍 Add to Cart` (forest green, full-width)
- **Secondary CTA:** `Buy Now` (warm-beige, goes straight to checkout)
- **Tertiary:** `❤ Save to Favorites` (ghost icon button)
- Show inline toast / success flash when item is added

---

### Phase 3 — Cart Drawer + Cart Page
**Scope:** Full cart experience.

```
components/cart/CartDrawer.vue  [NEW]
pages/CartPage.vue              [NEW]
```

**CartDrawer (`components/cart/CartDrawer.vue`):**
- Slides in from the right edge, triggered by `cartStore.isDrawerOpen`
- Dark backdrop overlay behind drawer
- Lists all cart items: thumbnail, name, price, qty stepper, remove (×)
- Footer section: subtotal, "View Full Cart" link, "Checkout" button
- Smooth CSS transition: `translate-x-full` → `translate-x-0`
- Close on backdrop click or `×` button

**CartPage (`pages/CartPage.vue`) — `/cart`:**
- **Left column:** Line items table
  - Product image + name + SKU
  - Quantity stepper (−/+)
  - Unit price + line total
  - Remove button
- **Right column:** Order summary card
  - Subtotal
  - Delivery estimate (free over ₱5,000, else ₱350)
  - Order total
  - `Proceed to Checkout →` primary button
- Empty cart state: illustration + "Start Shopping" CTA
- `← Continue Shopping` link back to catalog

---

### Phase 4 — Checkout Flow
**Scope:** The conversion funnel.

```
stores/checkout.ts                    [NEW]
pages/CheckoutPage.vue               [NEW]
pages/OrderConfirmationPage.vue      [NEW]
```

**CheckoutPage (`pages/CheckoutPage.vue`) — `/checkout`:**

3-step wizard with progress indicator:

| Step | Fields |
|:---|:---|
| **1. Shipping** | Full name, email, phone, address line 1 & 2, city, province, ZIP |
| **2. Payment** | COD (Cash on Delivery) · GCash (QR code shown) · Card (placeholder) |
| **3. Review** | Order summary, address recap, payment method, confirm & submit |

- Submit POSTs to `POST /api/orders`
- Auth guard: redirect to `/login?redirect=/checkout` if not authenticated
- Form validation on each step before proceeding

**OrderConfirmationPage — `/order-confirmation`:**
- Animated ✅ checkmark
- Order number (from API response)
- Delivery timeline estimate
- CTAs: `Continue Shopping` + `Design Your Room` (links to room planner)

---

### Phase 5 — Homepage & Footer Overhaul
**Scope:** First impressions and trust signals.

```
pages/HomePage.vue              [MODIFY]
components/common/AppFooter.vue [MODIFY]
```

**HomePage Changes:**
1. **Promo Strip** (top of page, above hero):  
   `🚚 Free delivery on orders over ₱5,000  ·  30-Day Returns  ·  1-Year Warranty`
2. **Hero CTA** — add `Shop Now →` as primary alongside `Design My Space`
3. **Trust Badges Strip** (below hero metrics):
   - 🚚 Free Delivery (₱5,000+)
   - 🔄 30-Day Returns
   - 🛡 1-Year Warranty
   - 🔒 Secure Checkout
4. **Deals / New Arrivals Banner** — horizontal card before featured products

**AppFooter Changes:**
- Remove: milestone tracker, capstone credits, tech stack badges
- Add:
  - Column 1: Brand + tagline + social links (Facebook, Instagram, TikTok)
  - Column 2: Shop links (All Furniture, Living Room, Bedroom, Home Office, Dining)
  - Column 3: Support links (FAQ, Shipping Policy, Returns, Contact Us)
  - Column 4: Newsletter email input + subscribe button
- Bottom bar: © SmartSpace · Privacy · Terms · Payment icons (Visa, Mastercard, GCash, COD)

---

### Phase 6 — Router Integration
**Scope:** Wire up new pages.

```
router/index.ts  [MODIFY]
App.vue          [MODIFY — add CartDrawer mount]
```

**New Routes:**

| Path | Name | Component | Guard |
|:---|:---|:---|:---|
| `/cart` | `cart` | `CartPage.vue` | None |
| `/checkout` | `checkout` | `CheckoutPage.vue` | Auth required |
| `/order-confirmation` | `order-confirmation` | `OrderConfirmationPage.vue` | Auth required |

**App.vue:**
- Mount `<CartDrawer />` globally so it overlays any page

---

## 🗃️ Data Architecture — New Types

```typescript
// New: CartItem (stores/cart.ts)
interface CartItem {
  id: number
  sku: string
  name: string
  price: number
  quantity: number
  primary_image: string | null
  category_name: string | undefined
  color: string
  color_hex: string
  dimensions: { width_cm: number; depth_cm: number; height_cm: number }
}

// New: CheckoutForm (stores/checkout.ts)
interface CheckoutForm {
  name: string
  email: string
  phone: string
  address: string
  city: string
  province: string
  zip: string
  payment_method: 'cod' | 'gcash' | 'card'
}

// New: Order (from API POST /api/orders)
interface Order {
  id: number
  order_number: string
  status: string
  total: number
  items: CartItem[]
  shipping_address: CheckoutForm
  created_at: string
}
```

---

## 🔧 Backend Requirements

> [!NOTE]
> The cart is **100% frontend** (localStorage + Pinia). No backend cart endpoint is needed.

| Endpoint | Method | Priority | Notes |
|:---|:---|:---|:---|
| `POST /api/orders` | POST | 🔴 Required for Phase 4 | Submit order, returns order number |
| `GET /api/orders/{id}` | GET | 🟡 Optional | Order detail for confirmation page |

The order request body:
```json
{
  "items": [{ "furniture_id": 1, "quantity": 2 }],
  "shipping": { "name": "...", "address": "...", "city": "...", ... },
  "payment_method": "cod",
  "total": 15000
}
```

---

## ✅ Verification Checklist

After implementation, test the full e-commerce funnel:

- [ ] Browse catalog → hover card → quick "Add to Cart" appears
- [ ] Cart badge in navbar increments correctly
- [ ] Cart drawer slides in when badge is clicked
- [ ] Cart drawer shows correct items, qty controls, subtotal
- [ ] Navigate to `/cart` — full cart page renders
- [ ] "Proceed to Checkout" redirects guests to login
- [ ] Authenticated user reaches `/checkout` — 3-step form works
- [ ] Submit order → reaches `/order-confirmation` with order number
- [ ] Cart clears after successful order
- [ ] All existing features still work: Room Planner, Favorites, 3D Viewer, Auth

---

## 🔗 Related Documentation

- [[09 - Improvement Roadmap/09 - Improvement Roadmap|09 - Improvement Roadmap]]
- [[07 - API/07 - API Specification & Contracts|07 - API Specification]]
- [[04 - Data/04 - Data Architecture & ERD|04 - Data Architecture]]
- [[02 - Services/02 - Services Overview|02 - Services Overview]]
