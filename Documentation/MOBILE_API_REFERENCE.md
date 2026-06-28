# 📱 Renty Mobile App — User API Reference

> **Base URL:** `https://starfish-app-vavqt.ondigitalocean.app`
> **Swagger Docs:** `https://starfish-app-vavqt.ondigitalocean.app/swagger`
> **OpenAPI JSON:** `https://starfish-app-vavqt.ondigitalocean.app/swagger/v1/swagger.json`

All responses follow a unified envelope:
```json
{
  "error": false,
  "messages": [],
  "data": { ... }
}
```
On error: `error: true`, `messages: ["Error description"]`, `data: null`.

---

## 📋 Table of Contents

1. [Authentication & Onboarding](#1-authentication--onboarding)
2. [Home Page](#2-home-page)
3. [Marketplace & Search](#3-marketplace--search)
4. [Item Details](#4-item-details)
5. [My Items (Owner)](#5-my-items-owner)
6. [Rentals](#6-rentals)
7. [Orders & Payments](#7-orders--payments)
8. [Wallet](#8-wallet)
9. [Favorites](#9-favorites)
10. [Chat](#10-chat)
11. [Support Tickets](#11-support-tickets)
12. [Notifications](#12-notifications)
13. [Profile & Account](#13-profile--account)
14. [Identity Verification](#14-identity-verification)
15. [Media Upload](#15-media-upload)
16. [Real-Time (SignalR)](#16-real-time-signalr)

---

## 1. Authentication & Onboarding

### Pages: Login, Register, Email Verification, Forgot/Reset Password

All auth endpoints are **public** (no token needed) unless noted.

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/auth/register` | `{ email, password, firstName, lastName, phoneNumber?, address?, city?, country?, bio? }` | Register a new user |
| `POST` | `/api/v1/auth/verify-email` | `{ email, code }` | Confirm email with 6-digit code |
| `POST` | `/api/v1/auth/send-verification` | `{ email }` | Resend verification email |
| `POST` | `/api/v1/auth/login` | `{ email, password }` | Login → returns tokens |
| `POST` | `/api/v1/auth/refresh` | `{ refreshToken }` | Refresh an expired access token |
| `POST` | `/api/v1/auth/forgot-password` | `{ email }` | Send password reset code |
| `POST` | `/api/v1/auth/verify-reset-code` | `{ email, code }` | Verify the reset code is valid |
| `POST` | `/api/v1/auth/reset-password` | `{ email, code, newPassword }` | Set new password |

### Login Response
```json
{
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "dGhpcyBp...",
    "refreshTokenExpiresAt": "2026-07-05T14:00:00Z",
    "user": {
      "id": 1,
      "firstName": "Hamza",
      "lastName": "Omran",
      "email": "hamza@example.com",
      "role": "user",
      "profilePictureUrl": "https://...",
      "permissions": ["Items_View", "Rentals_View", ...],
      "idVerificationStatus": "Pending",
      "idVerified": false,
      "isVerified": true
    }
  }
}
```

### Using the Token
Attach to **every authenticated request**:
```
Authorization: Bearer eyJhbGci...
```

### Scenario: Full Onboarding Flow
1. `POST /auth/register` → 201
2. `POST /auth/send-verification` (if email not auto-sent)
3. `POST /auth/verify-email` with code from email → 200
4. `POST /auth/login` → store `accessToken` & `refreshToken`
5. When token expires → `POST /auth/refresh` → new tokens

---

## 2. Home Page

### Page: Landing / Home Screen

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/recommendations` | ❌ | Get trending/recommended items |
| `GET` | `/api/v1/categories?page=1&limit=50` | ❌ | Get all categories for browsing |
| `PUT` | `/api/v1/recommendations/{id}/click` | ✅ | Track when user taps a recommended item |

---

## 3. Marketplace & Search

### Pages: Browse Items, Search Results, Filter

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/items` | ❌ | Browse all items with filters |
| `GET` | `/api/v1/search` | ❌ | Full-text search |

### GET /api/v1/items — Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number (required) |
| `limit` | int | Items per page (required) |
| `categoryId` | int? | Filter by category |
| `subcategoryId` | int? | Filter by subcategory |
| `city` | string? | Filter by city |
| `minPrice` | decimal? | Minimum price |
| `maxPrice` | decimal? | Maximum price |
| `startDate` | DateTime? | Available from date |
| `endDate` | DateTime? | Available until date |
| `minRating` | int? | Minimum rating (1-5) |
| `type` | string? | `"rent"` or `"sell"` |
| `condition` | string? | Item condition filter |
| `sort` | string? | Sort field (e.g. `"price"`, `"createdAt"`) |
| `sortOrder` | string? | `"asc"` or `"desc"` |
| `owner` | string? | Filter by owner ID |

### GET /api/v1/search — Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query (required) |
| `page` | int | Page number |
| `limit` | int | Results per page |
| `categoryId` | int? | Filter by category |
| `city` | string? | Filter by city |

### Response (Paginated)
```json
{
  "data": {
    "items": [ { "id": "guid", "title": "...", "price": 25.00, ... } ],
    "total": 120,
    "page": 1,
    "pages": 6
  }
}
```

---

## 4. Item Details

### Pages: Product Detail, Reviews, Availability Calendar

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/items/{id}` | ❌ | Get full item details |
| `GET` | `/api/v1/items/{id}/reviews` | ❌ | Get item reviews |
| `GET` | `/api/v1/items/{id}/availability` | ❌ | Get booked date ranges |
| `GET` | `/api/v1/items/{id}/remind` | ✅ | Check if user set a reminder |
| `POST` | `/api/v1/items/{id}/remind` | ✅ | Set availability reminder |
| `DELETE` | `/api/v1/items/{id}/remind` | ✅ | Remove reminder |
| `POST` | `/api/v1/items/{id}/favorite` | ✅ | Add to favorites |
| `DELETE` | `/api/v1/items/{id}/favorite` | ✅ | Remove from favorites |
| `GET` | `/api/v1/public-profile/{userId}` | ❌ | View the owner's public profile |

### Scenario: User Views an Item and Rents It
1. `GET /items/{id}` → display details, photos, price, owner info
2. `GET /items/{id}/availability` → show calendar with booked dates
3. `GET /items/{id}/reviews` → show ratings & comments
4. User picks dates → proceed to rental creation (Section 6)

---

## 5. My Items (Owner)

### Pages: My Listings, Create Item, Edit Item

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/items?owner=me&page=1&limit=20` | ✅ | Get the user's own items |
| `POST` | `/api/v1/items` | ✅ | Create a new item listing |
| `PUT` | `/api/v1/items/{id}` | ✅ | Update item details |
| `DELETE` | `/api/v1/items/{id}` | ✅ | Remove item from marketplace |
| `POST` | `/api/v1/items/{id}/reactivate` | ✅ | Reactivate a removed item |

### Create Item Body
```json
{
  "title": "Sony Camera A7III",
  "titleAr": "كاميرا سوني",
  "description": "Professional camera...",
  "descriptionAr": "كاميرا احترافية...",
  "categoryId": 3,
  "subcategoryId": 12,
  "brandId": 5,
  "price": 50.00,
  "pricingType": "daily",
  "depositAmount": 200.00,
  "condition": "Excellent",
  "city": "Amman",
  "address": "...",
  "imageIds": ["media-guid-1", "media-guid-2"],
  "type": "rent"
}
```

> [!TIP]
> Upload images first via `POST /api/v1/media` (Section 15), then pass the returned `id` values in `imageIds`.

---

## 6. Rentals

### Pages: Create Rental, My Rentals, Rental Details, Transfer Verification

This is the core business logic of Renty.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/rentals` | ✅ | Create a new rental request |
| `GET` | `/api/v1/rentals?page=1&limit=20&status=&role=` | ✅ | Get user's rentals (as renter or owner) |
| `GET` | `/api/v1/rentals/{id}` | ✅ | Get rental details |
| `PUT` | `/api/v1/rentals/{id}/confirm` | ✅ | Owner confirms the rental |
| `PUT` | `/api/v1/rentals/{id}/handoff` | ✅ | Set handoff method (ByHand/Delivery) |
| `PUT` | `/api/v1/rentals/{id}/verify-transfer` | ✅ | Verify transfer with OTP code |
| `PUT` | `/api/v1/rentals/{id}/complete?damaged=false` | ✅ | Complete the rental |
| `PUT` | `/api/v1/rentals/{id}/cancel` | ✅ | Cancel the rental |
| `POST` | `/api/v1/rentals/{id}/photos` | ✅ | Upload condition photos |
| `DELETE` | `/api/v1/rentals/{id}/photos?imageUrl=...` | ✅ | Delete a photo |
| `POST` | `/api/v1/rentals/{id}/extend` | ✅ | Renter requests extension |
| `PUT` | `/api/v1/rentals/{id}/extend/{extId}/respond` | ✅ | Owner approves/rejects extension |
| `PUT` | `/api/v1/rentals/{id}/request-expert` | ✅ | Request expert item review |
| `DELETE` | `/api/v1/rentals/{id}/request-expert` | ✅ | Cancel expert review request |
| `POST` | `/api/v1/rentals/{id}/dispute` | ✅ | Open a dispute |
| `PUT` | `/api/v1/rentals/{id}/possession?action=...&method=...` | ✅ | Update item possession state |
| `POST` | `/api/v1/rentals/{id}/transfers/handoff-from-hub` | ✅ | Generate handoff-from-hub transfers |
| `POST` | `/api/v1/rentals/{id}/transfers/expert-return` | ✅ | Generate expert return transfers |

### Create Rental Body
```json
{
  "itemId": "guid",
  "startDate": "2026-07-01T00:00:00Z",
  "endDate": "2026-07-05T00:00:00Z",
  "pricingType": "daily",
  "notes": "Please handle with care",
  "requestExpertReview": false
}
```

### Rental Lifecycle (State Machine)

```
Pending → Confirmed → HandoffScheduled → InProgress → Completed
                ↓                              ↓
              Cancelled                     Disputed
```

### Scenario: Complete Rental Flow (Renter)
1. `POST /rentals` → creates rental + order (status: `Pending`)
2. Wait for owner to `PUT /rentals/{id}/confirm` (status: `Confirmed`)
3. Owner sets `PUT /rentals/{id}/handoff` with `{ "handoffMethod": "ByHand" }`
4. Transfer codes are generated → both parties verify with `PUT /rentals/{id}/verify-transfer` + OTP code
5. Upload condition photos: `POST /rentals/{id}/photos`
6. When rental period ends: `PUT /rentals/{id}/complete?damaged=false`

### Scenario: Request Extension (Renter)
1. `POST /rentals/{id}/extend` with `{ "extraDays": 3 }`
2. Owner responds: `PUT /rentals/{id}/extend/{extId}/respond` with `{ "approve": true }`

### Scenario: Open Dispute
1. `POST /rentals/{id}/dispute` with `{ "reasonType": "Damaged", "description": "...", "mediaUrls": [...] }`

---

## 7. Orders & Payments

### Pages: Order Summary, Payment

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/orders` | ✅ | Get user's orders |
| `GET` | `/api/v1/orders/{id}` | ✅ | Get order details |
| `POST` | `/api/v1/orders` | ✅ | Create an order |
| `POST` | `/api/v1/payments` | ✅ | Create a payment for an order |
| `GET` | `/api/v1/payments/{orderId}` | ✅ | Get payment status by order |
| `GET` | `/api/v1/orders/{id}/delivery` | ✅ | Track delivery status |

### Create Payment Body
```json
{
  "orderId": "guid",
  "method": "wallet",
  "amount": 250.00
}
```

---

## 8. Wallet

### Pages: Wallet Dashboard, Top Up, Withdraw, Transaction History

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/wallet/balance` | ✅ | Get balance + pending balance |
| `GET` | `/api/v1/wallet/transactions` | ✅ | Get transaction history |
| `POST` | `/api/v1/wallet/topup` | ✅ | Top up wallet (simulated) |
| `POST` | `/api/v1/wallet/withdraw` | ✅ | Request withdrawal |

### Top Up Body
```json
{ "amount": 100.00 }
```

### Withdraw Body
```json
{ "amount": 50.00, "method": "bank_transfer", "accountDetails": "..." }
```

---

## 9. Favorites

### Pages: My Favorites

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/users/me/favorites` | ✅ | Get all favorited items |
| `POST` | `/api/v1/items/{id}/favorite` | ✅ | Add item to favorites |
| `DELETE` | `/api/v1/items/{id}/favorite` | ✅ | Remove from favorites |

---

## 10. Chat

### Pages: Chat List, Chat Room

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/chats` | ✅ | Get all user's chats |
| `POST` | `/api/v1/chats` | ✅ | Create a new chat (e.g. with item owner) |
| `GET` | `/api/v1/chats/{id}/messages` | ✅ | Get messages in a chat |
| `POST` | `/api/v1/chats/{id}/messages` | ✅ | Send a message |

### Create Chat Body
```json
{ "participantId": 42, "itemId": "guid" }
```

### Send Message Body
```json
{ "message": "Hello, is this available?", "mediaUrl": null }
```

### Real-Time Messages
Use SignalR hub at `/hubs/chat` for live message delivery (see Section 16).

---

## 11. Support Tickets

### Pages: My Tickets, Ticket Detail / Chat

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/support/tickets` | ✅ | Create a support ticket |
| `GET` | `/api/v1/support/tickets` | ✅ | Get user's tickets |
| `GET` | `/api/v1/support/tickets/{id}` | ✅ | Get ticket details + messages |
| `POST` | `/api/v1/support/tickets/{id}/messages` | ✅ | Send message in ticket |

### Create Ticket Body
```json
{
  "subject": "Payment issue",
  "category": "billing",
  "description": "I was charged twice for my rental",
  "priority": "high"
}
```

### Send Support Message Body
```json
{
  "message": "Here is a screenshot of the charge",
  "mediaUrl": "https://...",
  "messageType": "text"
}
```

---

## 12. Notifications

### Pages: Notification Center

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/notifications` | ✅ | Get all notifications |
| `PUT` | `/api/v1/notifications/{id}/read` | ✅ | Mark one as read |
| `PUT` | `/api/v1/notifications/read-all` | ✅ | Mark all as read |

### Real-Time Notifications
Use SignalR hub at `/hubs/notifications` for push notifications (see Section 16).

---

## 13. Profile & Account

### Pages: View Profile, Edit Profile, Delete Account

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/auth/me` | ✅ | Get current user's full profile |
| `PUT` | `/api/v1/auth/me` | ✅ | Update profile (name, phone, city, etc.) |
| `DELETE` | `/api/v1/auth/me` | ✅ | Delete account permanently |
| `GET` | `/api/v1/public-profile/{userId}` | ❌ | View another user's public profile |

### Update Profile Body
```json
{
  "firstName": "Hamza",
  "lastName": "Omran",
  "phoneNumber": "+962790000000",
  "city": "Amman",
  "address": "...",
  "country": "Jordan",
  "bio": "I love renting cameras",
  "profilePictureUrl": "https://..."
}
```

---

## 14. Identity Verification

### Pages: Phone Verification, ID Upload

Users must verify their identity before transacting.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/user/phone/request` | ✅ | Request phone OTP |
| `POST` | `/api/v1/user/phone/confirm` | ✅ | Confirm phone with OTP |
| `POST` | `/api/v1/user/id/upload` | ✅ | Upload government ID for verification |

### Phone Request Body
```json
{ "phoneNumber": "+962790000000" }
```

### Phone Confirm Body
```json
{ "phoneNumber": "+962790000000", "code": "123456" }
```

### ID Upload Body
```json
{
  "frontImageUrl": "https://...",
  "backImageUrl": "https://...",
  "idType": "national_id"
}
```

> [!IMPORTANT]
> Upload images first via `POST /api/v1/media`, then pass the returned URLs here.

---

## 15. Media Upload

### Used by: Item photos, ID verification, rental condition photos, chat attachments

| Method | Endpoint | Auth | Content-Type | Description |
|--------|----------|------|-------------|-------------|
| `POST` | `/api/v1/media` | ✅ | `multipart/form-data` | Upload a file (max 20MB) |

### Form Fields
- `file` — The file (image, video, PDF)
- `entityId` — Optional GUID of related entity
- `entityType` — Optional string (`"item"`, `"rental"`, etc.)

### Response
```json
{
  "data": {
    "id": "guid",
    "url": "https://res.cloudinary.com/...",
    "originalFileName": "photo.jpg",
    "fileExtension": ".jpg",
    "contentType": "image/jpeg",
    "fileType": "image",
    "fileSize": 1234567,
    "width": 1920,
    "height": 1080,
    "createdAt": "2026-06-28T14:00:00Z"
  }
}
```

---

## 16. Real-Time (SignalR)

### Hubs

| Hub | URL | Purpose |
|-----|-----|---------|
| Chat | `wss://starfish-app-vavqt.ondigitalocean.app/hubs/chat` | Live chat messages |
| Notifications | `wss://starfish-app-vavqt.ondigitalocean.app/hubs/notifications` | Push notifications |
| Support | `wss://starfish-app-vavqt.ondigitalocean.app/hubs/support` | Support ticket live chat |

### Connection
```
// Connect with JWT token
const connection = new HubConnectionBuilder()
  .withUrl("/hubs/notifications", { accessTokenFactory: () => jwtToken })
  .build();
```

### Events to Listen For

**Chat Hub:**
- `ReceiveMessage` — New chat message arrived
- `MessageSent` — Confirmation of sent message

**Notification Hub:**
- `ReceiveNotification` — New notification (rental confirmed, payment received, etc.)

**Support Hub:**
- `ReceiveMessage` — New support message
- `StatusChanged` — Ticket status updated
- `AssignmentChanged` — Agent assigned/unassigned

---

## 📐 App Pages Summary

| # | Screen | Key APIs |
|---|--------|----------|
| 1 | **Splash / Onboarding** | — |
| 2 | **Login** | `POST /auth/login` |
| 3 | **Register** | `POST /auth/register` → `POST /auth/verify-email` |
| 4 | **Forgot Password** | `POST /auth/forgot-password` → `POST /auth/verify-reset-code` → `POST /auth/reset-password` |
| 5 | **Home** | `GET /recommendations`, `GET /categories` |
| 6 | **Marketplace** | `GET /items?...` |
| 7 | **Search Results** | `GET /search?q=...` |
| 8 | **Item Details** | `GET /items/{id}`, `GET /items/{id}/reviews`, `GET /items/{id}/availability` |
| 9 | **Create Rental** | `POST /rentals` |
| 10 | **My Rentals** | `GET /rentals?role=renter`, `GET /rentals?role=owner` |
| 11 | **Rental Details** | `GET /rentals/{id}`, transfer verification, extension, dispute |
| 12 | **My Items** | `GET /items?owner=me` |
| 13 | **Create/Edit Item** | `POST /items`, `PUT /items/{id}`, `POST /media` |
| 14 | **My Orders** | `GET /orders` |
| 15 | **Order Details** | `GET /orders/{id}`, `GET /payments/{orderId}` |
| 16 | **Wallet** | `GET /wallet/balance`, `GET /wallet/transactions`, `POST /wallet/topup` |
| 17 | **Favorites** | `GET /users/me/favorites` |
| 18 | **Chat List** | `GET /chats` + SignalR `/hubs/chat` |
| 19 | **Chat Room** | `GET /chats/{id}/messages`, `POST /chats/{id}/messages` |
| 20 | **Notifications** | `GET /notifications` + SignalR `/hubs/notifications` |
| 21 | **Profile** | `GET /auth/me`, `PUT /auth/me` |
| 22 | **Public Profile** | `GET /public-profile/{userId}` |
| 23 | **Phone Verification** | `POST /user/phone/request`, `POST /user/phone/confirm` |
| 24 | **ID Verification** | `POST /media` → `POST /user/id/upload` |
| 25 | **Support Tickets** | `GET /support/tickets`, `POST /support/tickets` |
| 26 | **Ticket Chat** | `GET /support/tickets/{id}`, `POST /support/tickets/{id}/messages` |
| 27 | **About Us** | Static page (no API) |
| 28 | **Contact Us** | Static page (no API) |
