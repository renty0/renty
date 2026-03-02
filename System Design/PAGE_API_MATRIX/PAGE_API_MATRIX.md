# RENTY -- Frontend Pages x API Endpoints Matrix

> This document maps every frontend page to its API calls, required role, HTTP method, and purpose.
> Use this as the handoff spec between frontend and backend teams.

---

## 1. PUBLIC PAGES (No Auth Required)

### Register Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/register` | Create new user account |

### Verify Email Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/verify-email` | Confirm email via token |

### Login Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/login` | Authenticate and get JWT |

### Home Page
| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/items?featured=true` | Load featured items | No |
| GET | `/recommendations` | Load personalized recommendations | Yes (if logged in) |

### Browse / Catalog Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/items?category=&city=&minPrice=&maxPrice=&type=&sort=&page=` | Load filtered item list |
| GET | `/search?q=&category=&city=` | Full-text search |

### Search Results Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/search?q=&category=&city=&page=&limit=` | Search items + log to search_logs |

### Item Details Page
| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/items/:id` | Load full item detail | No |
| GET | `/items/:id/reviews` | Load item reviews | No |
| POST | `/items/:id/favorite` | Add to favorites | Yes |
| DELETE | `/items/:id/favorite` | Remove from favorites | Yes |

---

## 2. USER PAGES (Auth: user)

### Profile Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/auth/me` | Get current user profile |
| PUT | `/auth/me` | Update profile (name, phone, city, image) |

### Add Item Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/items` | Create new item listing |

### Edit Item Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/items/:id` | Load item data for editing |
| PUT | `/items/:id` | Update item (owner only) |

### My Items Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/items?owner=me` | Load items owned by current user |

### Favorites Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/users/me/favorites` | Get user's favorited items |
| DELETE | `/items/:id/favorite` | Remove from favorites |

### Rent Modal (on Item Details Page)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/rentals` | Request rental (validates availability, calculates price, checks fraud) |

### My Rentals Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/rentals?status=&page=&limit=` | Load rentals for current user |

### Rental Details Page
| Method | Endpoint | Purpose | Who Can Call |
|--------|----------|---------|-------------|
| GET | `/rentals/:id` | Load rental detail | renter or owner |
| PUT | `/rentals/:id/confirm` | Confirm rental request | owner only |
| PUT | `/rentals/:id/complete` | Mark rental as returned | owner only |
| PUT | `/rentals/:id/cancel` | Cancel rental | renter only (before confirmed) |

### Leave Review Page (on Rental Details)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/rentals/:id/review` | Submit rating + comment (completed rentals only) |

### Checkout Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/orders` | Create purchase order |

### Payment Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/payments` | Submit payment (vodafone_cash, fawry, etc.) |

### My Orders Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/orders?page=&limit=` | Load current user's orders |

### Order Details Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/orders/:id` | Load full order detail |
| GET | `/payments/:orderId` | Load payment status |
| GET | `/orders/:id/delivery` | Load delivery tracking |

### Chat List Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/chats` | Load all chats for current user |
| POST | `/chats` | Start new chat with another user |

### Chat Room Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/chats/:id/messages` | Load messages + mark as read |
| POST | `/chats/:id/messages` | Send new message |

### Notifications Page
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/notifications` | Load notifications + unread count |
| PUT | `/notifications/:id/read` | Mark single notification as read |
| PUT | `/notifications/read-all` | Mark all notifications as read |

### Support Page (Create Ticket)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/support/tickets` | Open new support ticket |
| GET | `/support/tickets` | Load user's own tickets |
| POST | `/support/tickets/:id/messages` | Reply to ticket |

---

## 3. EXPERT PAGES (Auth: expert)

### Expert Panel (Assigned Verifications)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/expert/assigned` | Load pending verification assignments |
| POST | `/items/:id/verify` | Submit verification result (approved/rejected + notes) |
| GET | `/items/:id/verifications` | View verification history for an item |

---

## 4. SUPPORT PAGES (Auth: support)

### Support Ticket Dashboard
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/support/tickets` | Load ALL tickets (not just own) |
| POST | `/support/tickets/:id/messages` | Reply to any ticket |
| PUT | `/support/tickets/:id/status` | Change ticket status (open/in_progress/resolved/closed) |

---

## 5. ADMIN PAGES (Auth: admin, super_admin)

### Admin Dashboard (KPIs)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/admin/kpis/latest` | Load latest KPI snapshot |
| GET | `/admin/kpis?period=&from=&to=` | Load KPI history |

### Admin Gap Analysis
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/admin/gap?period=&limit=` | Load supply-demand gap results |

### Admin Fraud Panel
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/admin/fraud?decision=&minRisk=&page=` | Load fraud logs |

### Admin Users Management
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/admin/users?page=&limit=` | Load all users with roles |
| PUT | `/admin/users/:id/status` | Activate/deactivate user (super_admin only) |

### Admin Support (shared with Support role)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/support/tickets` | Load all tickets |
| PUT | `/support/tickets/:id/status` | Update ticket status |
| POST | `/support/tickets/:id/messages` | Reply to ticket |

### Admin Item Management
| Method | Endpoint | Purpose |
|--------|----------|---------|
| PUT | `/items/:id` | Edit any item (suspend, update) |
| DELETE | `/items/:id` | Remove any item |
| POST | `/items/:id/verify` | Verify item or assign expert |
| GET | `/items/:id/verifications` | View verification history |

### Admin Delivery Management
| Method | Endpoint | Purpose |
|--------|----------|---------|
| PUT | `/orders/:id/delivery` | Update delivery status |

---

## 6. REVERSE MAP: API Endpoint -> Pages That Use It

| API Endpoint | Used By Pages |
|---|---|
| `POST /auth/register` | Register |
| `POST /auth/verify-email` | Verify Email |
| `POST /auth/login` | Login |
| `POST /auth/refresh` | All authenticated pages (auto) |
| `GET /auth/me` | Profile, App Shell (header) |
| `PUT /auth/me` | Profile |
| `GET /items` | Home, Browse, My Items |
| `GET /items/:id` | Item Details, Edit Item |
| `POST /items` | Add Item |
| `PUT /items/:id` | Edit Item, Admin Item Management |
| `DELETE /items/:id` | My Items, Admin Item Management |
| `GET /search` | Browse, Search Results |
| `POST /items/:id/favorite` | Item Details, Browse (heart btn) |
| `DELETE /items/:id/favorite` | Item Details, Favorites |
| `GET /users/me/favorites` | Favorites |
| `POST /rentals` | Rent Modal |
| `GET /rentals` | My Rentals |
| `GET /rentals/:id` | Rental Details |
| `PUT /rentals/:id/confirm` | Rental Details (owner view) |
| `PUT /rentals/:id/activate` | System (after payment) |
| `PUT /rentals/:id/complete` | Rental Details (owner view) |
| `PUT /rentals/:id/cancel` | Rental Details (renter view) |
| `POST /orders` | Checkout |
| `GET /orders` | My Orders |
| `GET /orders/:id` | Order Details |
| `POST /payments` | Payment |
| `GET /payments/:orderId` | Order Details |
| `GET /orders/:id/delivery` | Order Details |
| `PUT /orders/:id/delivery` | Admin Delivery |
| `POST /rentals/:id/review` | Leave Review (on Rental Details) |
| `GET /items/:id/reviews` | Item Details |
| `POST /items/:id/verify` | Expert Panel, Admin Item Management |
| `GET /items/:id/verifications` | Expert Panel, Admin Item Management, Rental Details |
| `GET /expert/assigned` | Expert Panel |
| `POST /support/tickets` | Support |
| `GET /support/tickets` | Support, Support Dashboard, Admin Support |
| `POST /support/tickets/:id/messages` | Support, Support Dashboard, Admin Support |
| `PUT /support/tickets/:id/status` | Support Dashboard, Admin Support |
| `POST /chats` | Chat List, Item Details (contact owner) |
| `GET /chats` | Chat List |
| `GET /chats/:id/messages` | Chat Room |
| `POST /chats/:id/messages` | Chat Room |
| `GET /notifications` | Notifications, App Shell (bell icon) |
| `PUT /notifications/:id/read` | Notifications |
| `PUT /notifications/read-all` | Notifications |
| `GET /recommendations` | Home |
| `PUT /recommendations/:id/click` | Home (when user clicks a rec) |
| `GET /admin/kpis` | Admin Dashboard |
| `GET /admin/kpis/latest` | Admin Dashboard |
| `GET /admin/gap` | Admin Gap Analysis |
| `GET /admin/fraud` | Admin Fraud Panel |
| `GET /admin/users` | Admin Users |
| `PUT /admin/users/:id/status` | Admin Users |

---

## 7. TOTAL COUNTS

| Metric | Count |
|---|---|
| Total API Endpoints | 48 |
| Total Frontend Pages | 30 |
| Public Pages (no auth) | 6 |
| User Pages | 17 |
| Expert Pages | 1 |
| Support Pages | 1 |
| Admin Pages | 7 |
