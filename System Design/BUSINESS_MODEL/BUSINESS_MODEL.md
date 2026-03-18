# RENTY — Business Model & Core Value Proposition

## 1. The Core Value Proposition

Renty is a secure, peer-to-peer marketplace for renting and buying sports equipment in Egypt. It serves local users who want to try sports without buying expensive gear, and sports tourists who don't want to travel with heavy equipment.

**The main problem it solves is Trust.** People are afraid to rent out expensive gear (fear of damage/theft) and afraid to rent from strangers (fear of getting broken gear).

Renty solves this through: escrow-held payments, mandatory deposits, Expert equipment inspections, AI fraud detection, and a two-way confirmation system.

---

## 2. Revenue Streams (How Renty Makes Money)

| Stream                    | Mechanism                                                                 | Rate                                      |
| ------------------------- | ------------------------------------------------------------------------- | ----------------------------------------- |
| **Rental Commission**     | Platform takes a % of every successful rental fee before paying the owner | Default 15% (configurable by Super Admin) |
| **Sales Commission**      | Platform takes a % of every item sold outright                            | Same rate                                 |
| **Expert Evaluation Fee** | Charged to the party who requests the Hub check (or split 50/50 if both)  | Fixed fee per inspection                  |

> **Note:** Commission % is locked at rental creation time. If Super Admin changes the rate, it only affects NEW rentals.

---

## 3. User Roles

| Role              | Description                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------------- |
| **User**          | Any registered person. Can act as Owner (lists items), Renter (rents items), Buyer, or Seller |
| **Expert**        | Certified technical inspector at a Renty Sales Point (Hub). Assigned by Admin                 |
| **Support Agent** | Handles user tickets, escalates to Admin                                                      |
| **Admin**         | Manages items, users, disputes, analytics, Expert assignments                                 |
| **Super Admin**   | Full system access. Staff CRUD, commission changes, overrides, maintenance mode               |

---

## 4. Identity & Trust System

### 4.1 Verification Levels

| Level              | What                                              | Required For                                   |
| ------------------ | ------------------------------------------------- | ---------------------------------------------- |
| **Email Verified** | Click verification link sent to email             | Account activation                             |
| **Phone Verified** | Enter OTP sent to phone (simulated for MVP)       | Renting / listing items                        |
| **ID Verified**    | Upload national ID (front + back) → Admin reviews | Renting high-value items, building trust badge |

### 4.2 Dual Rating System

Both sides of a transaction are rated independently:

- **Owner Rating:** How reliable is this person as an equipment lender? (Communication, item accuracy, handover punctuality)
- **Renter Rating:** How trustworthy is this person as a borrower? (Care of item, return punctuality, communication)

Ratings are 1-5 stars. Both parties can rate after a rental is completed. Neither can see the other's rating until both submit (prevents retaliatory reviews).

### 4.3 AI Fraud Detection

An Isolation Forest / One-Class SVM model generates a **risk score (0.0–1.0)** for every user:

| Score Range | Decision  | Action                                  |
| ----------- | --------- | --------------------------------------- |
| 0.0–0.49    | `safe`    | Normal access                           |
| 0.5–0.79    | `flagged` | Admin notified, user can still transact |
| 0.8–1.0     | `blocked` | Rental blocked, Admin must review       |

**Fraud indicators:** listing spikes, high cancellation rate, new account + high value, low review scores.

Admin can adjust the threshold, whitelist users, or permanently block them. Threshold changes show impact preview ("This will flag X additional users").

---

## 5. The Rental Lifecycle (Complete Flow)

### Rental State Machine

```
requested → confirmed → paid → in_delivery → active → returned → completed
                ↓                                ↓          ↓
            cancelled                        extended    disputed
```

### Step 1: Discovery & Negotiation

- Renters browse the catalog, use search (logged for Gap Analysis), or receive AI-driven recommendations.
- They can leave public comments on items (threaded, 3 levels max) or chat privately with the owner (**real-time via WebSocket**).
- Users can favorite items (favorites feed the recommendation engine).

### Step 2: Rental Request (Rent Modal)

- Renter selects start and end dates from the availability calendar.
- System auto-calculates: rental days × daily price, deposit, Expert fee (if requested), delivery fee (if applicable).
- Renter chooses: Expert check before (optional), Expert check after (optional).
- **Double-booking prevention:** System soft-locks the item's dates for 5 minutes. If checkout isn't completed, the lock expires.

### Step 3: Payment & Escrow (Checkout Modal)

- System displays: rental fee + deposit + Expert fee (if any) + delivery fee (if any) + platform commission (informational) = total.
- User selects payment method: Vodafone Cash, Fawry, Paymob, Credit Card, Bank Transfer.
- **Payment is simulated for MVP** — no real gateway integration.
- On success: `payments.status = 'success'`, `orders.status = 'paid'`, `rentals.status = 'paid'`.
- On failure: lock expires, dates released, user can retry.
- **All money is held in escrow** — it does NOT go to the owner yet.

### Step 4: The Optional Hub & Expert Evaluation (Trust Mechanic)

- **Direct Delivery (Standard):** For cheap/simple items, renter and owner meet up or use standard delivery.
- **The Hub Evaluation (Premium):** For expensive items, either party can request an Expert Check:
  1. Item goes to a Renty Sales Point (Hub).
  2. A certified Expert inspects it: condition rating (Excellent/Good/Fair/Poor/Unacceptable), detailed description, min 3 photos, functional test.
  3. Expert sets/confirms the required deposit.
  4. Renter reviews the report and **accepts or rejects** the item before taking it.
  5. **Continuity Rule:** The SAME Expert who did the pre-rental check MUST do the post-rental check (for consistency).
  6. **Who pays?** The person who requested it. If both → split 50/50.

### Step 5: Two-Way Confirmation

- **Handover confirmation:** Owner confirms item was handed over. Renter confirms item was received.
  - If only one party confirms → system waits 48h, then auto-confirms.
- **Return confirmation:** Renter confirms item was returned. Owner confirms item was received back.
  - Same 48h auto-confirm rule.

### Step 6: Completion & Payout

- Owner confirms receipt → `rentals.status = 'returned'`.
- If Expert post-check requested → Expert inspects, compares to pre-check report.
- **The Money Split:**
  - Renter gets deposit refunded (if no damage).
  - Renty takes its 15% commission from the Rental Fee.
  - Owner gets the remaining 85% of the Rental Fee → added to wallet.
- If damage: dispute path (see §7).

### Step 7: Late Returns

| Overdue Duration  | Action                                                                      |
| ----------------- | --------------------------------------------------------------------------- |
| 1–3 days          | Late fee = 150% of daily rate × overdue days. Charged from deposit first.   |
| 4–7 days          | Admin notified. Owner can escalate.                                         |
| 7+ days           | Support escalates. System generates legal PDF with identifying information. |
| Deposit exhausted | Renter's account flagged with debt. Cannot rent again until resolved.       |

---

## 6. Rental Extensions

- Renter requests extension with new end date → Owner gets notification.
- System calculates extra cost (days × daily rate).
- Owner approves or rejects within 48h (auto-reject if no response).
- Payment for extension must succeed before dates are updated.
- Multiple extensions allowed — each treated as a new request.

---

## 7. Cancellation Protection

Owners choose a cancellation policy per item:

| Policy       | Free Cancel Until   | After That                                                                   |
| ------------ | ------------------- | ---------------------------------------------------------------------------- |
| **Flexible** | 24h before start    | First day's rental fee is non-refundable. Deposit + remaining days refunded. |
| **Moderate** | 3 days before start | 50% of rental fee refunded. Full deposit refunded.                           |
| **Strict**   | 7 days before start | 0% of rental fee refunded. Full deposit refunded.                            |

- Platform commission may be non-refundable depending on timing.
- Owner cancellation: Owner can cancel an unstarted rental → Renter gets full refund. Repeat offenders flagged.

---

## 8. Dispute Resolution

1. **User files dispute** via Rental Details → Dispute Modal (evidence: photos, description, chat logs).
2. **Support Agent** reviews and either resolves or escalates to Admin.
3. **Admin** reviews evidence + Expert reports (if Hub was used). Actions:
   - Forfeit partial deposit (enter amount ≤ deposit, reason required).
   - Forfeit full deposit → Owner's wallet.
   - Additional charge (if damage > deposit value → Renter flagged with debt).
   - Override: refund Renter (emergency cases).
4. All dispute actions are **audit-logged** (who, when, what, amount).
5. **Super Admin** can reverse Admin's decision (clawback from Owner wallet if needed).

---

## 9. The Buying Flow

If an owner lists an item for sale:

1. Buyer adds to cart → checkout → pays full price.
2. Renty tracks delivery (`processing` → `shipped` → `delivered`). **Delivery tracking is simulated for MVP.**
3. Once delivered, Renty takes commission and pays seller.

---

## 10. Wallet System (MVP Simplified)

- **Owner earnings** come from completed rentals (85% of rental fee after commission).
- **Transaction history** derived from `payments`, `orders`, `rentals`.
- **Withdraw** → MVP: manual process. Production: automated payout.
- Balance = sum of completed rentals as owner − sum of withdrawals.
- Clawback: if Super Admin reverses a deposit forfeiture, Owner's balance may go negative (flagged for reconciliation).

---

## 11. Support System

- Users create support tickets (type: general, billing, dispute, report).
- **Support Agents** respond, change status (`open` → `in_progress` → `resolved`).
- **5-day auto-resolve:** If a ticket is `resolved` and user doesn't respond for 5 days → auto-closes.
- **Agent Ratings:** After resolution, user rates the agent (1-5 stars). Agents see their average + breakdown.
- **Escalation:** Agent can escalate to Admin with reason + suggested action + evidence.
- **Admin** can override, reassign, or force-close.

---

## 12. Real-Time Communication

| Feature           | Technology                      | Details                                                                                                              |
| ----------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Chat**          | WebSocket (Socket.IO / SignalR) | Real-time messaging between users with active/pending rentals. Typing indicators, read receipts (✓✓), online status. |
| **Notifications** | WebSocket + DB                  | 28+ event types pushed in real-time to bell icon. Stored in DB with `type` + `redirect_url` for click navigation.    |
| **Rental Status** | WebSocket                       | Live status banner updates on Rental Details page when status changes.                                               |
| **Fallback**      | REST polling                    | If WebSocket fails: chat polls every 10s, notifications every 30s.                                                   |

---

## 13. Advanced System Intelligence

### 13.1 Supply-Demand Gap Analysis

- Every search term is logged to `search_logs`.
- Nightly analytics pipeline: `gap_score = searches ÷ available_items` per category.
- Admins see top gaps by city, export CSV, and use this to recruit owners in undersupplied categories.

### 13.2 Fraud Detection

- Triggered on every rental request and payment.
- Isolation Forest / One-Class SVM model scores user behavior.
- Indicators: cancellation spikes, listing spikes (>10/day), low review avg, new account + high-value rental.
- Admin can block/whitelist/adjust threshold with impact preview.

### 13.3 Recommendation Engine

- Tracks: views, clicks, searches, favorites, rentals, reviews (`user_interactions` table).
- Algorithms: content-based, collaborative filtering, hybrid.
- Output: scored item suggestions on Home Page.
- Performance measured: CTR (click-through rate), conversion rate.

---

## 14. Admin Approval Gate

- All new item listings start with `status = pending_approval`.
- Admin reviews: title, description, photos, price, deposit, category.
- **Approve** → `available` (visible on marketplace). **Reject** → reason sent to owner.
- Items resubmitted 3+ times → flagged as suspicious.
- Major edits to approved items (title, price, deposit) → re-review required.

---

## 15. Item Reporting

- Any user can report a listing (reasons: fake listing, inappropriate, stolen, wrong category, spam).
- 3+ reports on same item → auto-flagged for Admin review.
- Admin can suspend or remove the item.

---

## 16. Platform Configuration (System Settings)

| Setting                                      | Default   | Who Can Change   |
| -------------------------------------------- | --------- | ---------------- |
| Platform Commission %                        | 15%       | Super Admin only |
| Default Cancellation Policy                  | Flexible  | Admin            |
| Expert Evaluation Fee                        | Varies    | Admin            |
| Auto-Resolve Days                            | 5         | Admin            |
| Fraud Threshold                              | 0.8       | Admin            |
| Late Fee Rate                                | 150%      | Admin            |
| Checkout Lock Duration                       | 5 minutes | Admin            |
| Feature Toggles (Buying, Hub, AI Recs, Chat) | All On    | Super Admin      |
| Maintenance Mode                             | Off       | Super Admin      |

All setting changes are **audit-logged** with timestamp + who changed it.

---

**Summary:**
Renty acts as a secure middleman. It makes money by taking a commission on successful rentals and sales. It builds trust by holding deposits in escrow, offering optional Expert evaluations with continuity guarantees, enforcing two-way confirmation, running AI fraud detection, and providing a real-time support system — ensuring both owners and renters are completely financially protected. The platform is governed by a tiered admin hierarchy (Support → Admin → Super Admin) with full audit trails on every financial and moderation decision.
