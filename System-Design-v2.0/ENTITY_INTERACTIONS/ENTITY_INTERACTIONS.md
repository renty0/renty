# RENTY — Entity Interaction Map (Full Edge-Case Coverage)

> This document maps **every interaction, flow, and edge case** between all system roles. Any User can act as both Owner and Renter. All user metrics (ratings, trust scores) are calculated as an average across both roles.

---

## 1. User Interactions

### 1.1 User ↔ System — Account Lifecycle

**1.1.1 Registration**
*   **Action:** User registers with: first name, last name, email, password, phone (optional), city.
*   **System:** Creates account with `is_verified = false`, `is_active = true`, `role_id = user`. Sends email verification link (stored in `email_verifications` table with expiry).
*   **Edge Cases:**
    *   If email already exists → show "Email already registered. Login instead?"
    *   If the verification link expires → user can request a new one from the login page.
    *   If user never verifies email → they can browse items but CANNOT rent, buy, list, or chat. A persistent banner says "Verify your email to unlock all features."
    *   If user tries to register with a disposable email domain → system blocks it and shows warning.

**1.1.2 Login / Logout**
*   **Action:** User logs in with email + password. System updates `last_login_at`.
*   **Edge Cases:**
    *   If wrong password 5 times → account is temporarily locked for 15 minutes. User is notified via email.
    *   If account is suspended (`is_active = false`) → login is blocked with message: "Your account has been suspended. Contact support."
    *   If account is logged in from a new device → notification sent: "New login from [device/location]."

**1.1.3 Password Reset**
*   **Action:** User clicks "Forgot Password" → enters email → receives reset link → sets new password.
*   **System:** Reset token stored with 1-hour expiry. Old sessions are invalidated after password change.
*   **Edge Cases:**
    *   If email doesn't exist → system shows the SAME success message as a valid email (to prevent email enumeration attacks).
    *   If token is expired → show "This link has expired. Request a new one."
    *   If user resets password while an active rental is in progress → rental is NOT affected.

**1.1.4 Identity Verification**
*   **Action:** User uploads national ID (front + back photos) and enters phone for OTP verification.
*   **System (Phone):** Sends OTP(simulation only) → user enters code → if correct → `phone_verified = true`.
*   **System (ID):** Stores images. Adds to Admin's ID Verification Queue. Admin reviews and sets `id_verified = true` or rejects with reason.
*   **Edge Cases:**
    *   If OTP expires (5 minutes) → user can request a new one. Max 3 OTP requests per hour.
    *   If Admin rejects the ID → user can re-upload with a different/clearer photo.
    *   If ID is blurry or unreadable → Admin rejects with reason "Photo is not clear enough."
    *   If user tries to rent a `premium` item without `id_verified = true` → system blocks with message: "ID verification required for premium items."
    *   If user changes their phone number after verification → `phone_verified` resets to `false` and they must re-verify.

**1.1.5 Profile Editing**
*   **Action:** User edits their name, phone, address, city, profile image.
*   **Edge Cases:**
    *   If user changes city → their listed items remain in the old city until manually updated.
    *   If user changes phone → `phone_verified` resets. They must re-verify.
    *   Email cannot be changed (immutable for security). User must contact Support.

---

### 1.2 User ↔ User — Marketplace Interactions

**1.2.1 Listing Equipment (Owner Flow)**
*   **Action (Owner):** Creates a new item listing: title, description, category, subcategory, condition, price/day (required), price/week (optional), price/month (optional), deposit, cancellation policy tier (`flexible`/`moderate`/`strict`), photos (min 1, max 10), location, sale toggle.
*   **System:** Validates all fields. Stores item with `status = pending_approval`. Sends notification to Admin queue.
*   **Edge Cases:**
    *   If Owner doesn't set a deposit → system requires a minimum deposit of 10% of the daily price × 7 days.
    *   If photos are too large (>2MB each) → system compresses or rejects with "File too large."
    *   If Owner lists a prohibited item (e.g., weapons) → Admin rejects with policy violation.
    *   If Owner edits an already-approved item with major changes (title, price, deposit, description) → item goes back to `pending_approval`. Minor changes (photos reorder) → stays `available`.
    *   If Owner has 3+ rejected listings → system raises a flag for Admin review (possible bad actor).
    *   If Owner tries to delete a listing with active rentals → system blocks deletion: "Cannot delete while rental is active."
    *   If Owner tries to list while their account is unverified → allowed, but item requires email verification to go live.

**1.2.2 Renting Equipment — Complete Flow**

**Step 1: Discovery**
*   Renter browses items via Home Page, Browse Page, or Search.
*   Renter can filter by: category, price range, location/city, availability dates, condition, owner rating.
*   System logs every search query in `search_logs` for Gap Analysis.

**Step 2: Item Details**
*   Renter views full details: photos, description, pricing, availability calendar, owner profile, reviews, comments, expert verification badge (if applicable).
*   **Edge Case:** If item was recently rented and calendar hasn't updated → system shows real-time availability from `rentals` table, not cached data.

**Step 3: Initiate Rental (Rent Modal)**
*   Renter selects start date and end date from the availability calendar.
*   System auto-calculates: rental days, total rental cost, deposit, expert fee (if requested), delivery fee to the sales point or the user (if requested by the owner or the renter).
*   Renter chooses: Expert check before (checkbox), Expert check after (checkbox).
*   **Edge Cases:**
    *   If selected dates overlap with an existing rental → dates are greyed out on calendar, selection blocked.
    *   If start date is today → blocked. Minimum is tomorrow.
    *   If rental duration exceeds 90 days → system warns "Consider contacting the owner for a long-term rate."
    *   If during the checkout flow another user rents the same item for overlapping dates → this user gets an error: "Item no longer available for these dates."

**Step 4: Checkout (Checkout Modal)**
*   System displays: rental fee, deposit, expert fee (if any), delivery fee (if any), platform commission (informational), total.
*   User selects payment method: Vodafone Cash, Fawry, Paymob, Credit Card, Bank Transfer.
*   User clicks "Pay" → button disables + loading spinner.
*   **System:** Soft-locks the item for these dates for 5 minutes. Creates `payments` record with `status = pending`.
*   **AI Fraud Check:** Before proceeding, the fraud module checks the Renter's risk score.
    *   If `safe` → continue.
    *   If `flagged` → block checkout, show "Your account is under review", auto-create Support ticket.
    *   If `blocked` → block checkout, show "Your account is suspended."
*   **Edge Cases:**
    *   If payment succeeds → `payments.status = success`, rental created with `status = requested`, Owner notified.
    *   If payment fails → `payments.status = failed`, user notified, item lock released, user can retry.
    *   If user closes browser during payment → lock expires after 5 minutes, dates released.
    *   If user clicks "Pay" twice (race condition) → second click is no-op because button is disabled. If somehow two requests hit the server → only the first is processed (idempotency key).
    *   If payment gateway is completely down → show "Payment service temporarily unavailable."
    *   If user's account balance is insufficient (for wallet payments) → show "Insufficient balance."

**Step 5: Owner Reviews Rental Request**
*   Owner receives notification: "New rental request for [Item] from [Renter]."
*   Owner views: Renter name, rating, dates, price, expert check requested?, Renter's `id_verified` status.
*   Owner can: **Approve** or **Reject** (with optional reason).
*   **Edge Cases:**
    *   If Owner doesn't respond within 24 hours → system sends a reminder. After 48 hours → system auto-rejects and refunds Renter 100%.
    *   If Owner tries to approve but dates are now conflicting (another rental was approved first) → system blocks and shows conflict error.
    *   If Owner rejects → Renter gets 100% refund. No penalty to Owner for rejecting.
    *   If Owner's account is suspended between request and approval → system auto-rejects all pending requests for this Owner.

**Step 6: Rental Active**
*   After Owner approves → `status = confirmed`.
*   After payment clears → `status = paid`.
*   After delivery/handover confirmed by both → `status = active`.
*   Renter has the item. The rental period is running.

**Step 7: Return Flow (Two-Way Confirmation)**
1.  Renter clicks "I have returned the item" → Renter's confirmation recorded.
2.  Owner clicks "I confirm I received the item back" → Owner's confirmation recorded.
3.  Both confirmed → `status = returned`.
4.  System checks for late fees. If none → `status = completed`, deposit refunded.
5.  If Expert post-check was requested → `status` stays `returned` until Expert verifies.
6.  Review Modal appears for both parties.
*   **Edge Cases:**
    *   If only Renter confirms but Owner doesn't within 48h → system sends Owner a reminder. After 72h → Support is notified.
    *   If only Owner confirms but Renter doesn't → same logic.
    *   If neither confirms after 72h → system sends both a final warning. After 96h → auto-completes if no dispute raised.
    *   If Owner claims item is damaged → Owner clicks "Report Issue" instead of "Confirm Return" → opens Dispute Modal.
    *   If item was sent via delivery and tracking shows "delivered" but neither party confirms → system sends reminder after 24h.

**1.2.3 Buying Equipment — Complete Flow**
*   Same checkout flow as renting, except:
    *   No start/end date — it's a one-time purchase.
    *   No deposit — full item price paid.
    *   No return expected — ownership transfers permanently.
    *   Item `status` changes to `removed` after purchase (no longer available).
    *   Owner cannot cancel after confirming a sale (100% buyer protection).
*   **Edge Cases:**
    *   If item has both rental and sale options, and someone rents it while another tries to buy → the active rental blocks the purchase until completed.
    *   If buyer claims item was not as described → standard dispute flow applies.

**1.2.4 Cancellations — Detailed Policy Rules**

**Flexible Policy:**
| Timing | Renter Refund | Owner Receives |
|--------|---------------|----------------|
| More than 24h before start | 100% rental fee + 100% deposit | Nothing |
| Less than 24h before start | 50% rental fee + 100% deposit | 50% of rental fee |
| After rental starts | 0% rental fee + 100% deposit | 100% of rental fee |

**Moderate Policy:**
| Timing | Renter Refund | Owner Receives |
|--------|---------------|----------------|
| More than 5 days before start | 100% rental fee + 100% deposit | Nothing |
| 1-5 days before start | 50% rental fee + 100% deposit | 50% of rental fee |
| Less than 24h before start | 0% rental fee + 100% deposit | 100% of rental fee |

**Strict Policy:**
| Timing | Renter Refund | Owner Receives |
|--------|---------------|----------------|
| More than 7 days before start | 50% rental fee + 100% deposit | 50% of rental fee |
| Less than 7 days before start | 0% rental fee + 100% deposit | 100% of rental fee |

**Owner Cancellation (All Policies):**
*   Owner cancels after confirming → 100% refund to Renter (rental fee + deposit).
*   Owner receives a penalty: search ranking reduction for 30 days + a `cancellation_fee` deducted from their wallet.
*   If Owner cancels 3+ times in 30 days → system auto-suspends their listings and flags for Admin review.

**Edge Cases:**
*   If both parties cancel simultaneously → Renter's cancellation takes priority (they get the refund).
*   If a dispute is opened and THEN one party cancels → cancellation is blocked: "Cannot cancel while a dispute is active."
*   If payment hasn't cleared yet and Renter cancels → payment is voided, no fee applies.
*   If Renter cancels after the rental has started → no rental fee refund, but deposit is ALWAYS refunded unless damage is proven.
*   Emergency cancellations (with proof) bypass all penalty rules — handled by Support escalation.

**1.2.5 Rental Extensions**
*   **Action (Renter):** From the Rental Details Page → Extend Modal. Selects new end date.
*   **System:** Calculates extra days × daily rate. Shows cost summary.
*   **Action (Owner):** Receives notification. Can Approve or Reject.
*   **If Approved:** System charges Renter for extra days. `end_date` updated. `status → extended`.
*   **If Rejected:** Renter notified. Original dates remain.
*   **Edge Cases:**
    *   If extension dates conflict with another existing rental → extension is blocked with "Item is booked for those dates."
    *   If Owner doesn't respond for 24h → system sends reminder. After 48h → auto-rejects extension.
    *   If Renter tries to extend after `end_date` has passed (overdue) → extension is NOT allowed. Only late fee applies.
    *   If Renter extends multiple times → each extension is treated as a new request. No limit on extensions as long as dates are available.
    *   Extension payment failure → extension request is cancelled, original dates remain.

**1.2.6 Communication (Chat)(real time)**
*   **Action:** Any two users can message each other if they have an active or pending rental, or if one is viewing the other's item.
*   **System:** Messages stored in `chat_messages`. Recipient gets `new_message` notification.
*   **Edge Cases:**
    *   If a user is suspended → they cannot send new messages. Existing chats become read-only.
    *   If a user blocks another user → not supported in MVP. Users can report via Support.
    *   If chat contains abusive language → not auto-detected in MVP. Users report via Support ticket.
    *   If user tries to share external payment links in chat (to bypass platform fees) → not auto-detected in MVP, but terms of service violation.
    *   Chat history is preserved indefinitely (or until account deletion).

**1.2.7 Public Comments (Q&A on Item Pages)**
*   **Action:** Any logged-in user can post a comment on an item listing.
*   **System:** Stored in `item_comments` with `parent_comment_id` for threading.
*   **Edge Cases:**
    *   If comment is on a deleted/suspended item → comments are hidden from public but preserved in DB.
    *   If a user is suspended → their comments remain visible (not deleted) but they cannot post new ones.
    *   If comment is reported as spam/abusive → Admin can delete it from Item Management.
    *   Empty comments → blocked by frontend validation.
    *   Maximum comment length: 1000 characters.
    *   Nested replies: max 3 levels deep (to prevent infinite nesting).

**1.2.8 Reputation / Trust (Dual Ratings)**
*   **After a completed rental:**
    *   Renter rates: (a) Item condition accuracy (1-5), (b) Owner service (1-5). Optional text review.
    *   Owner rates: (a) Renter behavior (1-5). Optional text review.
*   **System:** `owner_rating` = average of all Owner-service ratings received. `renter_rating` = average of all Renter-behavior ratings received. Stored on the `users` table.
*   **Edge Cases:**
    *   One review per rental per party. System blocks duplicate submissions.
    *   Reviews cannot be edited or deleted after submission. User must contact Support for extreme cases (e.g., accidental 1-star).
    *   If a rental is disputed → both parties can still leave reviews, but a "Disputed" badge appears on the review.
    *   If a user has 0 reviews → their rating shows "New User" instead of 0 stars.
    *   Review text is NOT moderated in real-time (MVP). Admin can remove abusive reviews manually.
    *   Both parties can submit reviews independently — no requirement to wait for the other.
    *   Reviews are only allowed when `status = completed`. System blocks reviews on `cancelled` or `disputed` rentals.

---

### 1.3 User ↔ Support

**1.3.1 Creating a Support Ticket**
*   **Action:** User navigates to Support Page → Create Ticket Modal.
*   **Fields:** Type (Payment Issue, Item Dispute, Account Issue, Bug Report, Other), Related Rental (optional dropdown), Description, Evidence upload (max 5 files).
*   **System:** Creates ticket with `status = open`. Assigns to available Support Agent (or enters unassigned pool).
*   **Edge Cases:**
    *   If user has 10+ open tickets → system warns "You have many open tickets. Please check existing ones first."
    *   If user submits a ticket about a rental that's already disputed → ticket is auto-linked to the existing dispute.
    *   Uploaded files: max 5MB each. Supported formats: jpg, png, pdf, mp4.

**1.3.2 Ticket Conversation**
*   **Action:** User and Support Agent exchange messages within the ticket.
*   **Edge Cases:**
    *   If Support resolves the ticket but user disagrees → user can reply, which automatically re-opens the ticket (`resolved → open`).
    *   If user doesn't respond for 5 days → system auto-resolves the ticket.
    *   If ticket is auto-resolved and user responds later → ticket re-opens.

**1.3.3 Rating the Support Agent**
*   **Action:** After ticket is resolved → "Rate your experience" appears. User gives 1-5 stars.
*   **Edge Cases:**
    *   If user doesn't rate → ticket still closes normally. Rating is optional.
    *   If user rates 1 star → no automatic action, but Admin can review agent performance trends.

---

### 1.4 User ↔ Expert (Indirect)

**1.4.1 Viewing Expert Reports**
*   **Action:** User sees the Expert's evaluation status on the Rental Details Page and Item Details Page.
*   **Displays:** Verification status badge (`pending`, `approved`, `rejected`), condition description, photos, Expert name.
*   **Edge Cases:**
    *   If Expert hasn't submitted the report yet → shows "Evaluation Pending."
    *   If item was rejected by Expert → Renter sees "Item Rejected by Expert — Full Refund Issued."

**1.4.2 Renter Accepts/Rejects Expert Report (Pre-Rental)**
*   After Expert approves the item and submits the report → Renter is notified.
*   Renter views the report and decides:
    *   **Accept** → rental proceeds to `active`.
    *   **Reject** → rental is cancelled, Renter gets 100% refund, Owner is notified, Expert fee is still charged to whoever requested it.
*   **Edge Cases:**
    *   If Renter doesn't respond within 48h → system sends reminder. After 72h → auto-accepts (rental proceeds).
    *   If Renter rejects after reading the report → no penalty to Renter (it's their right).

---

### 1.5 User ↔ System (Automated Workflows)

**A. Rental State Machine**

```
       ┌─────────────────────────────────────────────────────────┐
       │                    HAPPY PATH                           │
       │                                                         │
requested ──→ confirmed ──→ paid ──→ in_delivery ──→ active     │
       │                                          │              │
       │                                  ┌───extended ◄──┘     │
       │                                  │       │              │
       │                                  │   returned           │
       │                                  │       │              │
       │                                  │   completed          │
       │                                                         │
       │   DEVIATIONS (can happen from most states):            │
       │   ● cancelled (from: requested, confirmed, paid)       │
       │   ● disputed (from: active, extended, returned)        │
       └─────────────────────────────────────────────────────────┘
```

*   **Transitions are one-directional.** No state can go backwards except through Admin override.
*   Each transition triggers a notification to both parties.
*   Each transition is timestamped for audit.

**B. Notification System**

| Event | Recipient | Redirect | Trigger |
|-------|-----------|----------|---------|
| `rental_request_received` | Owner | Rental Requests | Renter submits rental |
| `rental_confirmed` | Renter | Rental Details | Owner approves |
| `rental_rejected` | Renter | My Rentals | Owner rejects |
| `payment_success` | Renter + Owner | Rental Details | Payment clears |
| `payment_failed` | Renter | Rental Details | Payment fails |
| `item_shipped` | Renter | Rental Details | Owner confirms shipment |
| `item_received` | Owner | Rental Details | Renter confirms receipt |
| `return_reminder` | Renter | Rental Details | 24h before `end_date` |
| `item_returned` | Owner | Rental Details | Renter confirms return |
| `rental_completed` | Both | Rental Details | Both parties confirmed |
| `extension_request` | Owner | Rental Details | Renter requests extension |
| `extension_approved` | Renter | Rental Details | Owner approves |
| `extension_rejected` | Renter | Rental Details | Owner rejects |
| `new_message` | Recipient | Chat Room | Other user sends message |
| `dispute_opened` | Other party + Support | Support/Rental Details | User opens dispute |
| `dispute_update` | Both parties | Rental Details | Support/Admin updates |
| `dispute_resolved` | Both parties | Rental Details | Admin closes dispute |
| `item_approved` | Owner | My Listings | Admin approves listing |
| `item_rejected` | Owner | My Listings | Admin rejects listing |
| `item_arrived_at_hub` | Both | Rental Details | Delivery status update |
| `late_fee_alert` | Renter | Rental Details | Overdue detected |
| `no_show_warning` | Both | Rental Details | Start date passed, no handover |
| `auto_cancelled` | Both | My Rentals | System auto-cancelled |
| `deposit_refunded` | Renter | Wallet | Deposit returned |
| `deposit_forfeited` | Both | Rental Details | Admin seized deposit |
| `new_review` | Recipient | Profile | Other party left review |
| `fraud_alert` | User | — | Account flagged |
| `account_suspended` | User | — | Admin suspended account |
| `owner_request_timeout` | Renter | My Rentals | Owner didn't respond in 48h |

*   **Storage:** All notifications stored in `notifications` table. `is_read` flag toggled on click.
*   **Email:** Optional email sent for critical events (payment, disputes, suspensions).

**C. Payment Gateway Flow**
*   **System creates `payments` record → calls payment gateway (simulated for MVP).**
*   On Success → `payments.status = success` → rental status advances.
*   On Failure → `payments.status = failed` → user notified, can retry.
*   **Refund Flow:** System creates a new `payments` record with negative amount and links to original payment.
*   **Edge Cases:**
    *   If refund fails (gateway error) → system retries 3 times over 24 hours. If all fail → Support is notified.
    *   If user paid via Fawry (offline) → refund is credited to wallet balance instead of Fawry.
    *   Platform commission is deducted only when the rental is `completed`. If cancelled → no commission.
    *   Partial refunds (from cancellation penalties) → calculated automatically based on policy tier.

**D. Delivery Tracking**
*   **Statuses:** `processing` → `to_hub` → `at_hub` → `hub_to_renter` → `delivered` → `renter_to_hub` → `hub_to_owner` → `returned`.
*   Both parties must confirm physical handover/receipt.
*   **Edge Cases:**
    *   If item is lost during delivery → Owner reports via Support. Admin investigates. If confirmed lost → full deposit transfers to Owner + potential additional charge to Renter.
    *   If delivery is delayed beyond start date → Renter can cancel with full refund regardless of policy.
    *   If item arrives damaged during delivery → delivery company liability (not Renter). Owner files claim with delivery company via Support.
    *   For self-pickup → no delivery tracking. Rental starts when both confirm meetup.

**E. Late Return Handling**
*   **Detection:** Background job runs hourly. Checks if `NOW() > end_date` AND `status` is still `active` or `extended`.
*   **Late Fee Calculation:** `late_days × (daily_rental_price × late_fee_rate%)`. Default `late_fee_rate` = 150% (1.5× daily rate as penalty).
*   **Escalation Timeline:**
    *   Day 1 overdue → Notification to Renter: "Your rental is overdue. Late fees are accumulating."
    *   Day 3 overdue → Second notification + notification to Owner.
    *   Day 7 overdue → Late fee likely exceeds deposit. System enables "Download Legal PDF" for Owner.
    *   Day 14 overdue → System auto-generates Support ticket: "Severe overdue case."
    *   Day 30 overdue → Admin is directly notified. Account may be suspended.
*   **Legal PDF Contains:** Rental contract (item, dates, price), Renter identity (name, national ID, phone, email, address), total outstanding balance, digital timestamp.
*   **Edge Cases:**
    *   If late fee exceeds deposit AND Renter's wallet has balance → system auto-deducts from wallet.
    *   If Renter disputes the late fee → dispute flow takes priority, late fee calculation pauses.
    *   If Renter returns item on day 2 but late → fee is calculated for 2 days only.

**F. Wallet / Payments Dashboard**
*   **Owner Earnings:** `rental_fee × (1 - platform_commission_percent/100)` per completed rental.
*   **Earnings are released:** Only after `status = completed` (both parties confirmed return + any Expert post-check done).
*   **Transaction Types:** `earning`, `deposit_held`, `deposit_refunded`, `deposit_forfeited`, `late_fee_charged`, `cancellation_penalty`, `expert_fee`, `withdrawal`.
*   **Edge Cases:**
    *   If a completed rental is later disputed and reversed by Admin → owner's earnings are clawed back from wallet.
    *   Minimum withdrawal amount: configurable in `system_settings` (default: 50 EGP).
    *   Withdrawal processing time: 3-5 business days (displayed to user).
    *   If withdrawal fails (wrong bank details) → money returns to wallet, user notified.

**G. No-Show & Auto-Cancellation**
*   **Grace Period:** 24 hours after start date.
*   **Detection:** If `status = paid` or `confirmed` and `start_date + 24h < NOW()` and no delivery/handover confirmation → system auto-cancels.
*   **Penalty Logic:**
    *   If Owner didn't show (no shipment/handover) → 100% refund to Renter + Owner ranking penalty.
    *   If Renter didn't show (Owner confirms shipment but Renter doesn't confirm receipt) → Renter loses cancellation fee per policy. Deposit refunded.
    *   If neither showed → both are notified, rental cancelled, full refund. Both get a minor "no-show" flag.
*   **Edge Cases:**
    *   If Owner shipped via delivery and tracking shows "in transit" → no-show is NOT triggered (delivery is still in progress).
    *   If both claim they showed up → dispute flow.

**H. Item Availability**
*   **Core Rule:** No queue. No waitlist. Item must be `available` to start a new rental.
*   **Calendar:** Booked dates are greyed out on the Item Details Page. Calculated from active `rentals` with `status IN (requested, confirmed, paid, in_delivery, active, extended)`.
*   **Edge Cases:**
    *   If a rental is cancelled → those dates immediately become available again.
    *   If an extension is approved → the new dates are blocked on the calendar.
    *   If two users try to rent the exact same dates at the exact same millisecond → DB-level constraint prevents overlap. One succeeds, one gets "Dates no longer available."
    *   If Owner has multiple identical items → each item is tracked independently with its own `item_id`.

**I. Admin Listing Approval Gate**
*   New item → `status = pending_approval` → Admin queue.
*   Admin approves → `status = available` → appears in search.
*   Admin rejects → `status = rejected` → Owner sees reason → can edit & resubmit.
*   **Edge Cases:**
    *   If Admin doesn't review within 72 hours → system sends Admin a reminder.
    *   Resubmitted items go back to the end of the approval queue.
    *   If an approved item is later found to violate policies → Admin can suspend it at any time.

**J. Search System**
*   **Logged Fields:** `user_id` (if logged in), `query text`, `category_id` (if filtered), `results_count`, `timestamp`.
*   Used by Admin Gap Analysis to identify supply/demand mismatches.
*   **Edge Cases:**
    *   If 0 results → system shows "No items found" with alternative category suggestions.
    *   If user searches a banned term → results are empty (no special error).
    *   Suspended/pending items NEVER appear in search results.

**K. Favorites**
*   Toggle behavior: click to favorite, click again to unfavorite.
*   Stored in `favorites` table with unique constraint on (`user_id`, `item_id`).
*   **Edge Cases:**
    *   If a favorited item is deleted/suspended → card shows greyed-out "No longer available."
    *   If user has 500+ favorites → pagination on Favorites Page.
    *   Favorites count feeds into the item's popularity ranking signal.

**L. Recommendation System**
*   **Inputs:** `user_interactions` (views, searches, favorites, past rentals), collaborative filtering (users similar to you liked X).
*   **Output:** Ranked list of suggested items on the Homepage.
*   **Edge Cases:**
    *   New user with no history → show popular items by city or overall.
    *   If user only rents cameras → avoid over-fitting (still show some variety).
    *   Never recommend items the user already owns/listed.
    *   Never recommend suspended or pending items.

**M. AI Fraud Detection**
*   **Triggers:** Checkout initiation, account creation (background), unusual patterns.
*   **Signals:** Many cancellations, disputes opened, new account renting premium items, multiple failed payments, inconsistent location data.
*   **Score:** 0.0 (safe) to 1.0 (definite fraud). Stored in `fraud_scores` table.
*   **Actions by Threshold:**
    *   < 0.5 → `safe`, no action.
    *   0.5 – 0.79 → `flagged`, rental proceeds but Admin is notified.
    *   ≥ 0.8 → `blocked`, rental is blocked, user is notified, Support ticket auto-created.
*   **Edge Cases:**
    *   False positive → Admin can whitelist the user from Fraud Panel.
    *   If a previously flagged user completes 5+ successful rentals without issues → score decays downward.
    *   Fraud score is recalculated daily by a background job.

**N. Auto-Resolve Stale Tickets**
*   If `ticket.status IN (open, in_progress)` AND last user reply was 5+ days ago → `status → resolved`.
*   System sends notification: "Your ticket was auto-resolved due to inactivity."
*   **Edge Cases:**
    *   If user replies after auto-resolve → ticket reopens (`resolved → open`).
    *   Tickets escalated to Admin are excluded from auto-resolve (they require human decision).
    *   Disputed rentals' tickets are excluded from auto-resolve.

---

## 2. Support Interactions

### 2.1 Support ↔ User
**Customer Service**
*   Support agents read tickets, reply, and resolve issues.
*   Ticket status flow: `open` → `in_progress` → `resolved` → `closed`.
*   Agent CANNOT: change financial data, issue refunds, modify fraud flags, suspend users.
*   **Rating:** User rates agent 1-5 stars after resolution. Agent's overall rating = average of all ratings.
*   **Edge Cases:**
    *   If agent hasn't replied within 4 hours → ticket priority auto-escalates to "High".
    *   If agent is reassigned mid-conversation → new agent sees full chat history + internal notes.
    *   Agent can add internal notes (visible to other staff, NOT to the user).
    *   Agents cannot modify or delete user messages within a ticket.

### 2.2 Support ↔ Admin
**Issue Escalation**
*   Support escalates when: deposit refund needed, fraud flag adjustment, user suspension, financial override.
*   Escalation includes: reason text, suggested action, attached evidence.
*   **Edge Cases:**
    *   If Admin doesn't respond to escalation within 24h → system sends Admin a reminder.
    *   Support can de-escalate (take back) a ticket if the user resolves the issue before Admin acts.
    *   Support can see the Admin's resolution but cannot modify it.

---

## 3. Expert Interactions

### 3.1 Expert ↔ System / Item

**3.1.1 Pre-Rental Verification**
*   Expert receives item at Hub. Inspects physical condition.
*   **Fills out:** Overall condition (Excellent/Good/Fair/Poor/Unacceptable), detailed description, photos (min 3), functional test result, estimated deposit (if not set by Owner).
*   **Verdict:** Approve or Reject.
*   If **Approved** → Renter notified. Renter can Accept (rental proceeds) or Reject (rental cancelled, refund).
*   If **Rejected** → rental auto-cancelled, Renter refunded 100%, Owner notified, fraud flag optional.
*   **Edge Cases:**
    *   If Expert loses internet while submitting → form preserves draft locally. Expert can retry.
    *   If Expert accidentally approves a damaged item → they can contact Admin to override within 2 hours.
    *   Expert cannot verify their own listed items (system blocks assignment by matching `user_id`).
    *   If the item is not received at the Hub after 48h → Expert marks as "Not Received" → Support ticket auto-created.

**3.1.2 Post-Rental Verification**
*   Same Expert who did the pre-check MUST do the post-check (Continuity Rule).
*   Expert compares current condition against their own pre-rental report.
*   **Verdict Options:**
    *   "No Damage" → deposit refunded to Renter.
    *   "Damage Found — Renter Liable" → recommended penalty amount → Admin makes final call.
    *   "Damage Found — Normal Wear" → not Renter's fault → deposit refunded.
*   **Edge Cases:**
    *   If the assigned Expert is unavailable (sick, quit) → Admin must manually reassign. System warns "Continuity Rule Violated" so Admin is aware.
    *   If Expert and Owner disagree on damage assessment → Admin reviews both Expert report and Owner's claim.
    *   If post-check is not completed within 7 days of return → system alerts Admin.
    *   Expert's post-rental verdict is a RECOMMENDATION. Admin's decision is final.

**3.1.3 Hub Rejection Scenario**
*   Item arrives at Hub → Expert opens it → broken/fake.
*   Expert selects "Reject" → enters rejection reason → optionally flags for fraud.
*   **System:** Rental auto-cancelled. Renter refunded 100%. Owner notified. If fraud flagged → Support ticket + Owner's fraud score increases.
*   **Edge Cases:**
    *   If Owner claims item was fine when shipped (delivery damage) → three-way dispute: Owner vs. Delivery vs. Expert assessment.
    *   Rejection photos are permanently stored as evidence.

### 3.2 Expert ↔ Admin
**Receiving Assignments**
*   Admin assigns items with: verification type (before/after), priority (normal/urgent), optional notes.
*   Expert sees assignments in their queue, sorted by priority then date.
*   **Edge Cases:**
    *   If Expert has 15+ items in queue → Admin sees "Heavy Workload" warning.
    *   If item is already assigned to another Expert → system blocks with conflict message.
    *   If Expert hasn't started an urgent assignment within 4 hours → Admin is notified.

**Performance Tracking**
*   Metrics: items checked today vs. daily target, weekly/monthly totals, average time per check, accuracy rate (% of verdicts matching Admin's final decision).
*   **Edge Cases:**
    *   If Expert consistently misses targets → Admin can lower their priority in queue or reassign.
    *   If Expert's accuracy rate drops below 70% → Admin is flagged to review.
    *   Target reminder notification sent at 4 PM daily if target not met.

---

## 4. Admin Interactions

### 4.1 Admin ↔ User
**Account Moderation**
*   Admin can: view any user's profile, rental history, transactions, fraud score. Suspend/unsuspend accounts. Approve/reject ID verifications.
*   **Edge Cases:**
    *   Suspending a user with active rentals → Warning shown. Active rentals are NOT auto-cancelled (Admin must decide per case).
    *   Suspended user's items are hidden from marketplace but NOT deleted.
    *   If Admin suspends the wrong user → Admin can unsuspend immediately. Action is audit-logged.

**Item Listing Approval**
*   Admin reviews pending items. Approves (→ `available`) or Rejects (→ `rejected` + reason).
*   **Edge Cases:**
    *   Admin can approve with notes: "Approved, but please update your description."
    *   If the same item is resubmitted 3+ times → flagged for attention.
    *   Admin can bulk-approve multiple standard items at once.

**Deposit Forfeiture**
*   Admin reviews dispute evidence (Expert report, photos, user claims).
*   Can: forfeit partial deposit, forfeit full deposit, issue additional charge (if deposit < damage), refund Renter.
*   **Edge Cases:**
    *   If deposit was already refunded before dispute was opened → forfeiture is not possible. Admin must contact Renter directly.
    *   All forfeiture decisions are logged with: amount, reason, Admin ID, timestamp.
    *   Admin can reverse a forfeiture within 48 hours. After 48h → Super Admin override required.

**Lost Item Handling**
*   Renter reports item lost → Support escalates → Admin reviews.
*   Admin seizes 100% deposit → transfers to Owner.
*   If deposit < item value → Admin flags additional debt on Renter's account.
*   **Edge Cases:**
    *   If Renter disputes the "lost" claim (says they returned it) → requires delivery tracking evidence or Expert post-check.
    *   If item value is extremely high (> 10,000 EGP) → Super Admin must approve the additional charge.
    *   Owner can download Legal PDF for items valued above the seized deposit.

### 4.2 Admin ↔ Support
*   Admin sees all escalated tickets. Can: resolve, reassign agent, force-close, escalate to Super Admin.
*   **Edge Cases:**
    *   If Admin resolves a ticket differently than Support suggested → Support sees the Admin's decision and reason.
    *   If ticket was escalated by mistake → Admin can de-escalate back to Support.

### 4.3 Admin ↔ Expert
*   Admin assigns items, sets daily targets, monitors performance, reviews Expert verdicts.
*   Admin can override Expert's verdict (e.g., Expert said "no damage" but Admin found evidence of damage).
*   **Edge Cases:**
    *   Override is logged and Expert is notified: "Your verdict on [Item] was overridden by Admin."
    *   Frequent overrides trigger a performance review flag.

### 4.4 Admin ↔ System Analytics
**KPIs:** Total revenue, active rentals, new users, pending listings, open disputes.
**Gap Analysis:** Search queries vs. available items. Highlights: "Users searched 'camera' 500 times this week, only 3 cameras available."
**Fraud Panel:** Risk scores, flagged transactions, threshold adjustments.
*   **Edge Cases:**
    *   If Admin changes fraud threshold from 0.8 to 0.6 → system shows preview: "This will flag X additional users."
    *   If Admin exports Gap Analysis data → CSV download with: search term, count, available items, gap score.

---

## 5. Super Admin Interactions

### 5.1 Staff Management
*   **Create** staff accounts (Admin, Support, Expert) with: name, email, role, temporary password, city/branch.
*   **Suspend/Unsuspend** staff. **Delete** staff (if no active assignments). **Change role** (promote/demote).
*   **Edge Cases:**
    *   Cannot delete the last Super Admin account.
    *   Cannot demote yourself (Super Admin cannot remove own Super Admin role).
    *   Staff creation is audit-logged: who created whom, when.
    *   If a deleted Expert had pending assignments → system reassigns to another Expert automatically.

### 5.2 System Override
*   Super Admin can reverse ANY Admin decision: deposit forfeitures, suspensions, item removals.
*   Can force-close disputes, take over from Admin, unsuspend users.
*   **Edge Cases:**
    *   Every override is permanently logged: who, when, what was changed, previous value, new value, justification.
    *   Cannot override another Super Admin's override without a justification note.
    *   If Super Admin reverses a deposit forfeiture → money is clawed back from Owner's wallet and returned to Renter.

### 5.3 Platform Configuration
*   Manages: `platform_commission_percent` (default 15%), default cancellation policy, expert evaluation fees, auto-resolve days, late fee rate, checkout lock duration, feature toggles (enable/disable buying, hub evaluations, AI recommendations).
*   **Maintenance Mode:** Puts entire platform offline. All users see "Under Maintenance."
*   **Audit Log:** Complete log of all system changes, staff actions, financial overrides. Exportable as CSV.
*   **Edge Cases:**
    *   Changing commission rate → only applies to **new** rentals. Existing rentals use the rate locked at creation time.
    *   If maintenance mode is toggled during active checkouts → those checkouts are auto-cancelled with full refund.
    *   Feature toggle for "buying" → if disabled, all "Buy" buttons disappear platform-wide. Existing completed purchases are unaffected.
