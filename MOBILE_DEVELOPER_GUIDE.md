# 📱 Renty Mobile Developer Guide — Rental Workflow

> **Last Updated:** July 2026  
> **Scope:** This guide documents the complete rental lifecycle for the **user-facing mobile app** (Flutter). It is synced from the web frontend (`Client/Web`) and the live backend APIs. **Do NOT assume** — every field, endpoint, and state transition here is verified against the actual code.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Rental Statuses Reference](#2-rental-statuses-reference)
3. [API Endpoints Reference](#3-api-endpoints-reference)
4. [Complete Rental Workflow](#4-complete-rental-workflow)
5. [Expert Review Path](#5-expert-review-path)
6. [Disputes](#6-disputes)
7. [Reviews](#7-reviews)
8. [Photo Upload Flow](#8-photo-upload-flow)
9. [Role Detection](#9-role-detection)
10. [Gap Analysis — Mobile vs Web](#10-gap-analysis--mobile-vs-web)
11. [Data Model — RentalDetailDto Key Fields](#11-data-model--rentaldetaildto-key-fields)
12. [File Map](#12-file-map)
13. [Testing Checklist](#13-testing-checklist)
14. [Quick Reference — API Service in Dart](#14-quick-reference--api-service-in-dart)

---

## 1. Architecture Overview

```
Flutter Mobile App
├── Pages
│   ├── create_rental_page.dart      ← Renter creates rental
│   ├── my_rentals_page.dart         ← List (renter tab + owner tab)
│   └── rental_detail_page.dart      ← All lifecycle actions live here
├── Core / Controllers
│   └── rentals_controller.dart      ← GetX controller for list/filters
└── Core / Services
    └── api_service.dart             ← Singleton access to generated API clients
```

The generated API client lives in `lib/api/lib/api/rentals_api.dart`. All calls go through `ApiService.rentals.*`.

**Key principle:** The mobile app serves both the **renter** AND the **owner** in the same app. Role is detected by comparing the logged-in user's ID (`sharedPref.getString('user_id')`) against `rental.ownerId` and `rental.renterId` from the API response.

---

## 2. Rental Statuses Reference

| Status | Meaning | Who sees actions |
|--------|---------|-----------------|
| `Pending` | Rental request submitted, awaiting owner decision | Owner: Confirm / Cancel. Renter: Cancel |
| `Confirmed` | Owner accepted; owner must now set delivery method | Owner: Set Handoff Method / Cancel. Renter: Cancel |
| `AwaitingPickup` | Transfers generated, item being handed to renter | Active transfer card shown |
| `Active` | Item is with the renter | Renter: Initiate Return. Owner: Complete when item returned |
| `Overdue` | End date passed, item not yet returned | Same as Active |
| `Returned` | Renter has signalled return, awaiting owner receipt | Owner: Complete Rental |
| `Completed` | Rental ended successfully | Review section shown to renter |
| `Cancelled` | Rental cancelled by either party | No actions |
| `Rejected` | Owner rejected (uses cancel endpoint) | No actions |
| `Disputed` | Open dispute submitted | Dispute info shown |

---

## 3. API Endpoints Reference

### 3.1 Rentals Core

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/rentals` | ✅ | Create rental request |
| `GET` | `/api/v1/rentals?page=1&limit=20&status=&role=` | ✅ | Get user's rentals list |
| `GET` | `/api/v1/rentals/{id}` | ✅ | Get full rental details |
| `PUT` | `/api/v1/rentals/{id}/confirm` | ✅ | Owner confirms rental |
| `PUT` | `/api/v1/rentals/{id}/handoff` | ✅ | Owner sets handoff method |
| `PUT` | `/api/v1/rentals/{id}/verify-transfer?code=XXXXXX` | ✅ | Verify transfer OTP |
| `PUT` | `/api/v1/rentals/{id}/complete?damaged=false` | ✅ | Owner completes rental |
| `PUT` | `/api/v1/rentals/{id}/cancel` | ✅ | Cancel rental |
| `PUT` | `/api/v1/rentals/{id}/possession?action=...&method=...` | ✅ | Update item possession |

### 3.2 possession endpoint — action values

| `action` | `method` | Who calls | When |
|----------|---------|----------|------|
| `initiate_return` | `ByHand` or `DeliveryService` | **Renter** | Renter wants to return item |
| `confirm_receipt` | `ByHand` | **Owner** | Owner received the returned item |
| `send_to_expert` | `ByHand`, `DeliveryService`, or `NearestLocation` | **Owner** | Send to expert hub |

### 3.3 Expert Review

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/rentals/{id}/expert-review` | ✅ | Request expert review |
| `DELETE` | `/api/v1/rentals/{id}/expert-review` | ✅ | Cancel expert review |
| `POST` | `/api/v1/rentals/{id}/generate-handoff-from-hub-transfers` | ✅ | Renter chooses how to receive from expert |
| `POST` | `/api/v1/rentals/{id}/generate-expert-to-owner-transfers` | ✅ | Owner: get item back from expert |

### 3.4 Photos

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/media/upload` | ✅ | Upload file → returns `mediaId` |
| `POST` | `/api/v1/rentals/{id}/photos` | ✅ | Associate photo with rental |
| `DELETE` | `/api/v1/rentals/{id}/photos?url={url}` | ✅ | Delete rental photo |

### 3.5 Disputes & Reviews

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/rentals/{id}/disputes` | ✅ | Open dispute |
| `POST` | `/api/v1/reviews/{rentalId}` | ✅ | Submit review |

### 3.6 Chat

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/chats` | ✅ | Create/get chat with another user |

---

## 4. Complete Rental Workflow

### 4.1 Step 1 — Create a Rental Request (Renter)

**Page:** `create_rental_page.dart`  
**When:** Tapping "Rent Now" on `item_detail_page.dart`

#### UI Elements:
- Item context card (image, title, owner name)
- Date range picker (Start Date → End Date)
- Pricing type selector (Daily / Weekly / Monthly)
- **Notes** text area (optional message to owner)
- **Request Expert Review** checkbox (+100 EGP added to total)
- Price breakdown: Rental Price + Deposit + Expert Fee = Total
- Cancellation policy expandable section
- "Submit Rental Request" button

#### API Call:
```
POST /api/v1/rentals
{
  "itemId": "string",
  "startDate": "2025-07-10T00:00:00.000Z",
  "endDate": "2025-07-15T00:00:00.000Z",
  "pricingType": "daily",
  "notes": "Handle with care",
  "requestExpertReview": false
}
```

> 💡 On success, the system holds the full amount (rental + deposit) in escrow automatically.

---

### 4.2 Step 2 — Owner Accepts or Rejects (Owner)

**Status:** `Pending`  
**User:** Owner

#### Actions card shows:
1. **Expert Review checkbox** — "Request Expert Review (+100 EGP)" (only if `ownerWantsExpertReview === false`)
2. **Confirm Rental** button (primary)
3. **Cancel Rental** button (danger outlined)

#### If owner checks Expert Review AND confirms:
```
// Sequential calls:
POST /api/v1/rentals/{id}/expert-review   ← first
PUT  /api/v1/rentals/{id}/confirm         ← second
```

#### If owner confirms without expert:
```
PUT /api/v1/rentals/{id}/confirm
→ Status: Pending → Confirmed
```

#### If owner cancels:
```
PUT /api/v1/rentals/{id}/cancel
→ Money returned to renter escrow
→ Status: Cancelled
```

> ⚠️ **MOBILE GAP:** Current mobile is missing the **Expert Review checkbox** in the owner's Pending actions. Must be added before the Confirm button.

---

### 4.3 Step 3 — Owner Sets Delivery Method (Owner)

**Status:** `Confirmed`  
**User:** Owner

#### UI (Confirmed state — owner side):
- Label: "How would you like to deliver?" (or "How to deliver to expert?" if expert involved)
- Radio buttons:
  - **By Hand** — meet in person
  - **Delivery Service** — simulated for now
- "Set Delivery Method" button

#### API Call:
```
PUT /api/v1/rentals/{id}/handoff
{ "handoffMethod": "ByHand" }
```

#### What happens after:
- Backend **generates the transfers array** — each transfer has a `verificationCode` (OTP)
- Status: Confirmed → `AwaitingPickup`
- Active transfer card now appears on both sides

> ⚠️ **MOBILE GAP:** Current mobile shows only an "Activate" button for Confirmed status, which skips directly to OTP input. The owner MUST call `/handoff` first to generate the transfers and OTP codes. A delivery method selection UI is needed for the **owner in Confirmed state**.

---

### 4.4 Step 4 — Renter Uploads Handover Photos (Renter)

**Status:** `Confirmed`, `AwaitingPickup`, or `InTransit`  
**User:** Renter

The renter photographs the item **before** entering the OTP. The 30-minute rule applies: photos must be taken within the last 30 minutes.

#### Upload (2-step):
```
// Step 1: Upload the file
POST /api/v1/media/upload
form-data: entityId={rentalId}, entityType="Rental", file=<binary>
→ Response: { data: { id: "mediaId123" } }

// Step 2: Associate with rental
POST /api/v1/rentals/{id}/photos
{ "imageIds": ["mediaId123"], "type": "Handover" }
```

> ⚠️ **MOBILE GAP:** Currently uses `ImagePicker.gallery`. Should use `ImageSource.camera` for handover photos to enforce fresh capture.

---

### 4.5 Step 5 — Transfer Verification / OTP Handoff

This is the core handoff mechanism using the `transfers` array.

#### Transfer Object Fields:
```json
{
  "id": "string",
  "sequence": 1,
  "fromActorType": "Owner",
  "toActorType": "Renter",
  "phase": "Handover",
  "status": "Pending",
  "verificationCode": "123456",
  "completedAt": null
}
```

#### Finding the active transfer:
```dart
final activeTransfer = rental.transfers?.firstWhereOrNull(
  (t) => t.sequence == rental.currentTransferSequence && t.status != 'Verified'
);
```

#### Who shows code, who enters it:

| `fromActorType` | `toActorType` | Scenario | Code shown to | Code entered by |
|----------------|--------------|----------|--------------|----------------|
| Owner | Renter | Handover | **Owner** | **Renter** |
| Renter | Owner | Return | **Renter** | **Owner** |
| Expert | Renter | Handoff from expert | **Expert** (web) | **Renter** |

**Rule:** `fromActorType === currentUserRole` → **display the code**. `toActorType === currentUserRole` → **enter the code**.

#### API to verify:
```
PUT /api/v1/rentals/{id}/verify-transfer?code=123456
→ Correct: transfer status → Verified, next transfer activates
→ Final verification: status → Active
```

> ⚠️ **CRITICAL MOBILE GAP:** Mobile currently uses a `handoffCode` field and calls `/verify-handoff`. The **correct** endpoint is `PUT /api/v1/rentals/{id}/verify-transfer?code=XXX` using the `transfers` array. This must be fixed.

---

### 4.6 Step 6 — Rental is Active

**Status:** `Active` (or `Overdue`)  
**currentPossession:** `Renter`

#### Renter sees:
- Possession badge: "With Renter"
- **"Initiate Return"** button → opens return method selector

#### Owner sees:
- Possession badge: "With Renter"
- Info: "Waiting for renter to return the item"
- If `currentPossession === 'InTransit'`: **"Confirm Receipt"** button

#### Chat:
Both roles see Chat button → navigates to `ChatRoomPage` (create/get chat via `POST /api/v1/chats`)

---

### 4.7 Step 7 — Renter Returns the Item

**User:** Renter  
**currentPossession:** `Renter`

#### Flow:
1. Tap **"Initiate Return"** → show return method selector
2. Choose **By Hand** → confirm:

```
PUT /api/v1/rentals/{id}/possession?action=initiate_return&method=ByHand
→ currentPossession: Renter → InTransit
```

3. **Owner** uploads **Return Photos** (same 2-step process, type: `"Return"`)
4. **Return transfer OTP card** appears:
   - `fromActorType: "Renter"`, `toActorType: "Owner"`
   - **Renter shows code** → **Owner enters it**

5. After OTP verified: status → `Returned`

---

### 4.8 Step 8 — Owner Completes Rental

**User:** Owner  
**Status:** `Returned` or item back with owner

```
// If item in transit, owner confirms receipt first:
PUT /api/v1/rentals/{id}/possession?action=confirm_receipt&method=ByHand

// Then complete:
PUT /api/v1/rentals/{id}/complete?damaged=false   // or damaged=true
→ Status: Completed
→ Deposit released (or retained if damaged)
```

#### Damaged checkbox:
- Owner checks "Item is damaged" before completing
- If `damaged=true`: deposit retained, dispute likely to follow

#### After completion:
- Status → `Completed`
- **Review section** appears for **renter only** (not owner)

---

## 5. Expert Review Path

Expert = a third-party professional who inspects the item before and after rental. Expert uses the **web dashboard** at `/expert/verify/{itemId}`.

### When expert is involved:
- Renter checked "Request Expert Review" at creation, OR
- Owner checked expert checkbox at confirmation

### Standard vs Expert path:

```
Standard:
  Owner → Renter  (handover)
  Renter → Owner  (return)

With Expert:
  Handover: Owner → Expert → Renter
  Return:   Renter → Expert → Owner
```

### Expert Key Fields in DTO:

| Field | Type | Meaning |
|-------|------|---------|
| `renterWantsExpertReview` | bool | Set at creation |
| `ownerWantsExpertReview` | bool | Set at confirmation |
| `assignedExpertId` | int? | Null = pending assignment |
| `assignedExpertName` | string? | Expert's name |
| `verifications[]` | array | Expert check results |
| `verifications[].checkType` | string | `"BeforeRent"` or `"AfterReturn"` |
| `verifications[].status` | string | `"Pending"`, `"Approved"`, `"Rejected"` |
| `verifications[].notes` | string? | Expert's notes |
| `deliveryMethodFromExpert` | string? | How renter receives from expert |

### Expert API Calls:

```
// Owner requests expert at confirmation (call BEFORE confirm):
POST /api/v1/rentals/{id}/expert-review

// Cancel expert request:
DELETE /api/v1/rentals/{id}/expert-review

// Renter chooses how to receive from expert (when BeforeRent approved):
POST /api/v1/rentals/{id}/generate-handoff-from-hub-transfers
Body: { "method": "ByHand" }

// Owner chooses how to get item back from expert (return phase):
POST /api/v1/rentals/{id}/generate-expert-to-owner-transfers
Body: { "method": "ByHand" }
```

### Mobile UI needed for Expert:
- Expert Review card showing:
  - Status icon (hourglass = pending, check = approved, X = rejected)
  - Expert name (or "Not yet assigned")
  - Expert notes (if any)
  - "Cancel Expert Review" button (if pending and current user requested it)
  - "BeforeRent" and "AfterReturn" labels
- When `currentPossession === 'Expert'` and `BeforeRent` approved AND no `deliveryMethodFromExpert`:
  - Show renter a "How would you like to receive from expert?" radio selector
  - Call `generate-handoff-from-hub-transfers`

---

## 6. Disputes

**Available when status is:** `active`, `completed`, `overdue`, `returned`, `confirmed`, `disputed`

### UI (Bottom Sheet):
- Header with gavel icon
- Warning info box: "Disputes are reviewed by our team"
- **Reason dropdown** (choose one):
  - `Item not as described`
  - `Item damaged`
  - `Late delivery`
  - `Payment issue`
  - `Other`
- **Description** textarea (required description)
- Cancel / Submit buttons

### API Call:
```
POST /api/v1/rentals/{id}/disputes
{
  "reasonType": "Item damaged",
  "description": "Screen was cracked when I received it.",
  "mediaUrls": []
}
→ Status: Disputed
```

---

## 7. Reviews

**Available when:** `status === 'Completed'` AND current user is **Renter** AND `rental.hasReview === false`

### UI:
- Star rating 1–5 (interactive, tappable stars)
- Rating label: Poor / Below Average / Average / Good / Excellent
- Optional comment text field
- "Submit Review" button

### API Call:
```
POST /api/v1/reviews/{rentalId}
{
  "rentalId": "abc123",
  "rating": 5,
  "comment": "Great experience!"
}
```

---

## 8. Photo Upload Flow

| Photo Type | Uploaded by | When (status) |
|-----------|------------|--------------|
| Handover | **Renter** | `Confirmed`, `AwaitingPickup`, `InTransit` |
| Return | **Owner** | `Active`, `Overdue`, `Returned` |

### Two-Step Upload:
```
// Step 1: Upload file to media service
POST /api/v1/media/upload
multipart/form-data:
  entityId   = {rentalId}
  entityType = "Rental"
  file       = <binary>
→ Response: { data: { id: "mediaId123" } }

// Step 2: Associate with rental
POST /api/v1/rentals/{id}/photos
{ "imageIds": ["mediaId123"], "type": "Handover" }
```

### Delete Photo:
```
DELETE /api/v1/rentals/{id}/photos?url={photoUrl}
// Only available if img.canDelete === true in response
```

### The 30-Minute Rule:
Photos must be fresh (taken within last 30 min) before OTP entry. Use `ImageSource.camera` to enforce. If using gallery, validate EXIF `dateTimeOriginal` and warn if older than 30 minutes.

---

## 9. Role Detection

```dart
// In rental_detail_page.dart:
final currentUserId = sharedPref.getString('user_id');
final bool isOwner  = data.ownerId?.toString() == currentUserId;
final bool isRenter = data.renterId?.toString() == currentUserId;
```

For transfers:
```dart
// currentUserRole for transfer display
String get currentUserRole {
  if (isOwner) return 'Owner';
  if (isRenter) return 'Renter';
  return 'Unknown';
}

// Active transfer card logic:
if (activeTransfer.fromActorType == currentUserRole) {
  // SHOW the verification code to this user (they are the sender)
  display(activeTransfer.verificationCode);
} else if (activeTransfer.toActorType == currentUserRole) {
  // This user ENTERS the code (they are receiving)
  showInputField();
}
```

For chat:
```dart
// Target: the OTHER person in the rental
final targetUserId = isOwner ? rental.renterId : rental.ownerId;
final targetName   = isOwner ? rental.renterFirstName : rental.ownerFirstName;
```

---

## 10. Gap Analysis — Mobile vs Web

| Feature | Web | Mobile (Current) | Status |
|---------|-----|-----------------|--------|
| Create rental: Notes field | ✅ | ✅ | Synced |
| Create rental: Expert Review checkbox | ✅ | ✅ | Synced |
| My Rentals: Renter/Owner tabs | ✅ | ✅ | Synced |
| My Rentals: Status filters | ✅ | ✅ | Synced |
| Detail: Correct OTP via `transfers` array | ✅ | ✅ | Synced |
| Detail: Sender shows code, receiver enters | ✅ | ✅ | Synced |
| Detail: Owner handoff method at Confirmed | ✅ Radio + `/handoff` | ✅ Radio + `/handoff` | Synced |
| Detail: Expert checkbox at Owner confirm | ✅ | ✅ | Synced |
| Detail: Expert Review status card | ✅ | ✅ | Synced |
| Detail: Cancel Expert Review button | ✅ | ✅ | Synced |
| Detail: Renter receive-from-expert options | ✅ | ✅ | Synced |
| Detail: Transfer history card | ✅ | ✅ | Synced |
| Detail: Notes section (show renter's notes) | ✅ | ✅ | Synced |
| Detail: Late fee display | ✅ | ✅ | Synced |
| Detail: Renter/Owner parties card | ✅ Both shown | ✅ Both shown | Synced |
| Detail: Handover photos — camera capture | ✅ | ✅ | Synced |
| Detail: Return photos — owner upload | ✅ Active/Overdue/Returned | ✅ Active/Overdue/Returned | Synced |
| Detail: Delete photos (canDelete flag) | ✅ | ✅ | Synced |
| Detail: Dispute on `returned` status | ✅ | ✅ | Synced |
| Detail: Review for renter only | ✅ | ✅ | Synced |
| Image lightbox (tap to enlarge) | ✅ | ✅ | Synced |

---

## 11. Data Model — RentalDetailDto Key Fields

```dart
// Returned by GET /api/v1/rentals/{id}
class RentalDetailDto {
  String? id;
  String? itemId;
  String? itemTitle;
  String? itemImageUrl;

  int? ownerId;
  String? ownerFirstName;
  String? ownerCity;

  int? renterId;
  String? renterFirstName;

  String? status;             // see status table
  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;

  double? rentalPrice;        // total rental cost
  double? depositAmount;      // security deposit held
  double? lateFee;            // accrued if overdue
  String? depositStatus;      // "Held" | "Released" | "Retained"

  String? notes;              // renter's note at creation

  bool? renterWantsExpertReview;
  bool? ownerWantsExpertReview;
  int? assignedExpertId;
  String? assignedExpertName;

  String? currentPossession;  // "Owner" | "Renter" | "Expert" | "InTransit"
  int? currentTransferSequence;

  List<TransferDto>? transfers;
  List<ExpertVerificationDto>? verifications;
  List<RentalImageDto>? handoverImages;  // { url, canDelete }
  List<RentalImageDto>? returnImages;

  bool? hasReview;
  String? deliveryMethodFromExpert;
}
```

---

## 12. File Map

| File | Role |
|------|------|
| `lib/pages/create_rental_page.dart` | Create rental UI — notes, expert, price breakdown |
| `lib/pages/my_rentals_page.dart` | Rental list — renter/owner tabs, status filters |
| `lib/pages/rental_detail_page.dart` | All lifecycle actions (partially complete) |
| `lib/core/controllers/rentals_controller.dart` | GetX controller for list page |
| `lib/core/services/api_service.dart` | `ApiService.rentals`, `.media`, `.reviews`, `.chat` |
| `lib/api/lib/api/rentals_api.dart` | Generated API client — all rental calls |
| `lib/pages/chat_room_page.dart` | Chat UI — navigated from detail page |
| `lib/main.dart` | App root — `sharedPref` global |

---

## 13. Testing Checklist

Use **two accounts**: Account A (Owner), Account B (Renter). Open web app for expert page.

### Standard Flow (No Expert):

- [ ] **B** creates rental on item owned by **A** → status: `Pending`
- [ ] **A** opens "Rentals of My Items" tab → sees rental
- [ ] **A** opens detail, Pending actions: Confirm (no expert) / Cancel
- [ ] **A** confirms → status: `Confirmed`
- [ ] **A** (Confirmed): selects "By Hand" → taps "Set Delivery Method" → calls `/handoff`
- [ ] Status → `AwaitingPickup`, transfers array populated
- [ ] Active transfer: `fromActorType=Owner`, `toActorType=Renter`
  - **A (Owner)** sees their code (fromActorType = Owner = currentUserRole)
  - **B (Renter)** enters the code (toActorType = Renter)
- [ ] **B** uploads handover photos (camera) first
- [ ] **B** enters A's code → calls `/verify-transfer?code=...` → status: `Active`
- [ ] **B** sees "Initiate Return" → chooses "By Hand" → calls `/possession?action=initiate_return&method=ByHand`
- [ ] **A** uploads return photos
- [ ] Return transfer appears: `fromActorType=Renter`, `toActorType=Owner`
  - **B (Renter)** shows code
  - **A (Owner)** enters B's code → calls `/verify-transfer?code=...`
- [ ] **A** unchecks "damaged" → taps "Complete Rental" → calls `/complete?damaged=false`
- [ ] Status → `Completed`, **B** sees review section
- [ ] **B** submits review → rating + comment

### Expert Flow:

- [ ] **B** creates rental with "Request Expert Review" checked
- [ ] **A** (Pending): checks expert checkbox → taps Confirm → calls expert-review then confirm
- [ ] Expert opens web at `/expert/verify/{itemId}` → approves BeforeRent
- [ ] **B** sees "How to receive from expert?" → selects By Hand → calls `/generate-handoff-from-hub-transfers`
- [ ] Transfer: Expert → Renter. Expert shows code (web), **B** enters it.
- [ ] Status → `Active`, item with Renter
- [ ] Same return flow as standard, but Renter → Expert → Owner
- [ ] Expert approves AfterReturn on web
- [ ] **A** calls `/generate-expert-to-owner-transfers` → Expert → Owner transfer
- [ ] **A** completes rental

### Dispute:

- [ ] Open any `active` / `completed` rental → tap "Open Dispute"
- [ ] Select reason + description → Submit → status: `Disputed`

---

## 14. Quick Reference — API Service in Dart

```dart
// ── Create Rental ──
await ApiService.rentals.createRental(CreateRentalRequest(
  itemId: 'item123',
  startDate: DateTime(2025, 7, 10),
  endDate: DateTime(2025, 7, 15),
  pricingType: 'daily',
  notes: 'Handle with care',
  requestExpertReview: false,
));

// ── Get Rental List ──
await ApiService.rentals.getRentals(1, 15, role: 'renter', status: null);

// ── Get Rental Detail ──
await ApiService.rentals.getRentalById(rentalId);

// ── Confirm Rental (owner) ──
await ApiService.rentals.confirmRental(rentalId);

// ── Set Handoff Method (owner, Confirmed state) ──
await ApiService.client.invokeAPI(
  '/api/v1/rentals/$rentalId/handoff', 'PUT', [],
  jsonEncode({'handoffMethod': 'ByHand'}),
  {'Content-Type': 'application/json'}, {}, 'application/json',
);

// ── Verify Transfer OTP (CORRECT endpoint) ──
await ApiService.rentals.verifyTransfer(rentalId, '123456');
// Note: DO NOT use verify-handoff — use verify-transfer

// ── Update Possession (initiate return / confirm receipt) ──
await ApiService.client.invokeAPI(
  '/api/v1/rentals/$rentalId/possession?action=initiate_return&method=ByHand',
  'PUT', [], null, {}, {}, null,
);

// ── Complete Rental (owner) ──
await ApiService.rentals.completeRental(rentalId, isDamaged);

// ── Cancel Rental ──
await ApiService.rentals.cancelRental(rentalId);

// ── Request Expert Review ──
await ApiService.client.invokeAPI(
  '/api/v1/rentals/$rentalId/expert-review', 'POST',
  [], null, {}, {}, null,
);

// ── Cancel Expert Review ──
await ApiService.client.invokeAPI(
  '/api/v1/rentals/$rentalId/expert-review', 'DELETE',
  [], null, {}, {}, null,
);

// ── Upload Photo Step 1 (media upload) ──
final uploaded = await ApiService.media.uploadMedia(
  entityId: rentalId, entityType: 'Rental', file: multipartFile,
);
final mediaId = uploaded?.data?.id;

// ── Upload Photo Step 2 (associate with rental) ──
await ApiService.client.invokeAPI(
  '/api/v1/rentals/$rentalId/photos', 'POST', [],
  jsonEncode({'imageIds': [mediaId], 'type': 'Handover'}),
  {'Content-Type': 'application/json'}, {}, 'application/json',
);

// ── Delete Photo ──
await ApiService.rentals.deleteRentalPhoto(rentalId, photoUrl);

// ── Open Dispute ──
await ApiService.rentals.openRentalDispute(rentalId, OpenDisputeBody(
  reasonType: 'Item damaged',
  description: 'Screen was cracked.',
  mediaUrls: [],
));

// ── Submit Review ──
await ApiService.reviews.createReview(rentalId, CreateReviewCommand(
  rentalId: rentalId,
  rating: 5,
  comment: 'Great experience!',
));

// ── Start Chat ──
final res = await ApiService.chat.createChat(CreateChatCommand(
  userId: targetUserId,  // ownerId (if renter) or renterId (if owner)
));
final chatId = res?.data?.chatId;
// Navigate to ChatRoomPage(chatId: chatId, otherUserName: ...)
```

---

> **Expert Web Dashboard:** The expert logs in on the web at `/expert/verify/{itemId}`. The mobile app does NOT have an expert role — it only shows expert review status to owners and renters.
