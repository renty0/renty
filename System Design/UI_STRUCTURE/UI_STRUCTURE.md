# RENTY — Full UI Structure Specification (Exhaustive Edge-Case Coverage)

> Every page, modal, action, edge case (and sub-case), global layout, and navigation element — defined and ready for frontend + backend implementation.

---

## 1. GLOBAL LAYOUT & NAVIGATION

### 1.1 User App Global Layout

Every page in the User App shares this persistent shell:

**Top Bar (Header)**
| Element | Behavior |
|---------|----------|
| **Logo** | Top-left. Click → Home Page. Always visible |
| **Search Bar** | Center. Visible on all pages. Submit → Browse Page with query |
| **Notification Bell** | Top-right. Badge shows unread count. Click → Notification Dropdown. If 0 unread → no badge |
| **Chat Icon** | Top-right (next to bell). Badge shows unread messages count. Click → Chat List Page |
| **Profile Avatar** | Top-right corner. Click → dropdown: My Profile, My Rentals, My Listings, Wallet, Favorites, Settings, Support, Logout |
| **"List Your Item" Button** | Prominent CTA. Click → Add Item Page. Hidden if user is not email-verified (show tooltip: "Verify email first") |

**If NOT Logged In:**
| Element | Replaces |
|---------|----------|
| **Login Button** | Replaces Avatar, Bell, Chat. Click → Login Page |
| **Register Button** | Next to Login. Click → Register Page |
| Search bar + Logo remain visible |

**Bottom Navigation (Mobile Only)**
| Icon | Route |
|------|-------|
| Home | `/` |
| Browse | `/browse` |
| Add Item (+) | `/items/new` |
| My Rentals | `/my-rentals` |
| Profile | `/profile` |

**Footer (All Pages)**
| Section | Links |
|---------|-------|
| Company | About Us, Careers, Press |
| Support | Help Center / FAQ, Contact Us, Safety |
| Legal | Terms of Service, Privacy Policy, Cookie Policy |
| Social | Facebook, Instagram, Twitter icons |

### 1.2 Admin Panel Global Layout

**Sidebar Navigation (Always Visible)**
| Item | Route |
|------|-------|
| Dashboard | `/admin/dashboard` |
| Item Management | `/admin/items` |
| User Management | `/admin/users` |
| Disputes | `/admin/disputes` |
| Support Tickets | `/admin/support` |
| Analytics | `/admin/analytics` |
| Expert Management | `/admin/experts` |
| Settings | `/admin/settings` |

**Top Bar:** Logo (left) + Notification Bell + Admin Name & Avatar (right, dropdown: Profile, Logout)

### 1.3 Expert Panel Global Layout

**Sidebar Navigation**
| Item | Route |
|------|-------|
| Dashboard | `/expert/dashboard` |
| My Queue | `/expert/queue` |
| History | `/expert/history` |
| Performance | `/expert/performance` |

**Top Bar:** Logo + Notification Bell + Expert Name & Avatar (dropdown: Profile, Logout)

### 1.4 Support Panel Global Layout

**Sidebar Navigation**
| Item | Route |
|------|-------|
| Dashboard | `/support-panel/dashboard` |
| Tickets | `/support-panel/tickets` |
| Performance | `/support-panel/performance` |

**Top Bar:** Logo + Notification Bell + Agent Name & Avatar (dropdown: Profile, Logout)

### 1.5 Super Admin Panel Global Layout

**Sidebar:** Everything from Admin sidebar PLUS: Staff Management (`/super-admin/staff`), Super Settings (`/super-admin/settings`), Overrides (`/super-admin/overrides`)

**Top Bar:** Same as Admin with "Super Admin" role badge

---

## 2. AUTHENTICATION PAGES

### 2.1 Login Page

**Route:** `/login`
**Top Bar:** Logo only (no search, no nav). "Don't have an account? Register" link
**Type:** Full page (no sidebar)

#### Contains

| Field                               | Validation                 |
| ----------------------------------- | -------------------------- |
| Email                               | Required, valid format     |
| Password                            | Required, min 8 chars      |
| "Remember Me" checkbox              | Extends session to 30 days |
| **Login Button**                    | Submit form                |
| "Forgot Password?" link             | → Forgot Password Page     |
| Social Login Buttons (optional MVP) | Google, Facebook           |

#### Edge Cases (Full Depth)

- **Wrong password:**
  - Attempt 1-4 → "Incorrect email or password" (generic to prevent email enumeration).
  - Attempt 5 → Account locked for 15 minutes. Show: "Too many failed attempts. Try again in 15 minutes." Email sent: "Someone tried to access your account."
  - After lockout expires → counter resets.
- **Suspended account:** → "Your account has been suspended. Contact support at support@renty.com" with a "Contact Support" button.
- **Email not verified:** → Login succeeds BUT user lands on a page with a banner: "Please verify your email. [Resend Verification]". They can browse but cannot rent/list/chat.
- **Already logged in:** → Redirect to Home Page. `/login` is not accessible while authenticated.
- **Session expired:** → Redirect to Login with message: "Your session expired. Please log in again."

---

### 2.2 Register Page

**Route:** `/register`
**Top Bar:** Logo only. "Already have an account? Login" link

#### Contains

| Field               | Validation                                                  |
| ------------------- | ----------------------------------------------------------- |
| First Name          | Required, 2-50 chars, letters only                          |
| Last Name           | Required, 2-50 chars, letters only                          |
| Email               | Required, valid format, unique                              |
| Password            | Required, min 8 chars, 1 uppercase, 1 number                |
| Confirm Password    | Must match password                                         |
| Phone (optional)    | Egyptian format (+20)                                       |
| City                | Dropdown of Egyptian cities                                 |
| **Register Button** | Submit                                                      |
| Terms checkbox      | "I agree to Terms of Service and Privacy Policy" (required) |

#### Edge Cases

- **Email already exists:** → "This email is already registered. [Login instead?]"
- **Weak password:** → Real-time indicator: "Password must contain at least 8 characters, 1 uppercase, 1 number"
- **Disposable email:** → "Please use a valid email address" (system checks against disposable domain list)
- **After registration:** → Redirect to "Check Your Email" page. User receives verification email with link (expires in 24h).
  - If link expires → "This link has expired. [Resend verification email]"
  - If link already used → "Email already verified. [Go to Login]"
- **Already logged in:** → Redirect to Home Page

---

### 2.3 Forgot Password Page

**Route:** `/forgot-password`
**Top Bar:** Logo only

#### Flow

1.  User enters email → clicks "Send Reset Link"
2.  **Always** show: "If this email is registered, you'll receive a reset link." (prevents email enumeration)
3.  Email contains link → `/reset-password?token=xxx` (expires in 1 hour)

#### Reset Password Page (`/reset-password`)

| Field            | Validation               |
| ---------------- | ------------------------ |
| New Password     | Min 8, 1 upper, 1 number |
| Confirm Password | Must match               |

#### Edge Cases

- **Expired token:** → "This reset link has expired. [Request a new one]"
- **Already used token:** → "This link has already been used. [Request a new one]"
- **Invalid token:** → "Invalid link. [Request a new one]"
- **After reset:** → All existing sessions invalidated. Redirect to Login with: "Password changed successfully. Please log in."

---

### 2.4 Email Verification Page

**Route:** `/verify-email?token=xxx`
**Top Bar:** Logo only

#### States

- **Success:** "Email verified! [Go to Home Page]"
- **Expired:** "This link has expired. [Resend verification email]" → user enters email → new link sent
- **Already verified:** "Your email is already verified. [Go to Home Page]"
- **Invalid token:** "Invalid verification link."

---

### 2.5 Error Pages

**404 — Not Found**

- **Route:** Any unmatched route
- **Top Bar:** Full navigation (if logged in)
- **Content:** "Page not found" illustration + "Go to Home Page" button + Search bar

**403 — Forbidden**

- **Content:** "You don't have permission to access this page." + "Go to Home Page"
- **When:** User tries to access admin/expert/support routes without proper role

**500 — Server Error**

- **Content:** "Something went wrong. We're working on it." + "Try Again" button + "Contact Support" link

**Maintenance Mode**

- **Content:** "We're currently performing maintenance. We'll be back shortly." + estimated time (if set by Super Admin)

---

## 3. USER APP — COMPLETE PAGE STRUCTURE

### 3.1 Home Page

**Route:** `/`
**Top Bar:** Full navigation (search, bell, chat, avatar, "List Your Item")

#### Sections

| Section                    | Description                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------- |
| **Hero Banner**            | Seasonal/promotional banner. Can be a carousel. Click → relevant category or item       |
| **Search Bar (Prominent)** | Large search field + location auto-suggest + "Search" button                            |
| **Category Tiles**         | Scrollable row of sport categories with icons (Diving, Surfing, Camping, Cycling, etc.) |
| **Recommended Items**      | AI-personalized cards (from views, searches, favorites, past rentals)                   |
| **Popular Items**          | Highest-rated items in user's city                                                      |
| **Recently Added**         | Newest approved listings                                                                |

#### Actions

| Action                         | Result                                    |
| ------------------------------ | ----------------------------------------- |
| Search submit                  | → Browse Page with query params           |
| Click category tile            | → Browse Page filtered by category        |
| Click item card                | → Item Details Page                       |
| Click "See All" on any section | → Browse Page filtered/sorted accordingly |

#### Edge Cases

- **New user (no history):** → "Recommended" section shows popular items instead. Label changes to "Popular Near You."
- **No city set:** → Show items from all cities + banner: "Set your city for better recommendations. [Set City]"
- **No items in user's city:** → Show items from nearest cities + "No items in [City] yet. Browse all locations?"
- **User not logged in:** → Recommendations section hidden. Show "Sign up to get personalized recommendations" CTA.

---

### 3.2 Browse Page

**Route:** `/browse` or `/browse?q=surfboard&category=water-sports&city=cairo`
**Top Bar:** Full navigation

#### Contains

| Element                          | Description                                                              |
| -------------------------------- | ------------------------------------------------------------------------ |
| **Active Filters Bar**           | Shows applied filters as removable chips/tags at the top                 |
| **Filter Panel**                 | Sidebar (desktop) / Bottom sheet (mobile). Collapsible                   |
| **Item Cards Grid**              | Responsive: 4 cols desktop, 2 cols tablet, 1 col mobile                  |
| **Sort Dropdown**                | Top-right: Relevance, Price (low-high), Price (high-low), Rating, Newest |
| **Results Count**                | "Showing 42 items"                                                       |
| **Pagination / Infinite Scroll** | Load 20 items per page/scroll                                            |

#### Filter Options

| Filter          | Type                 | Details                                                    |
| --------------- | -------------------- | ---------------------------------------------------------- |
| Category        | Dropdown             | All categories from DB                                     |
| Subcategory     | Dropdown             | Depends on category selection                              |
| Price Range     | Slider               | Min-Max (per day)                                          |
| Location/City   | Dropdown + "Near Me" | Egyptian cities                                            |
| Availability    | Date picker          | Start-End dates. Only show items available for these dates |
| Condition       | Checkboxes           | New, Like New, Good, Fair                                  |
| Owner Rating    | Min stars            | 1-5 slider                                                 |
| Expert Verified | Toggle               | Show only Expert-verified items                            |

#### Item Card Contents

| Element                 | Detail                                 |
| ----------------------- | -------------------------------------- |
| Primary image           | First photo                            |
| Title                   | Max 2 lines, truncated                 |
| Price/day               | Bold, primary color                    |
| Rating                  | Stars + count (e.g., "4.5 ★ (23)")     |
| Location                | City name                              |
| Heart icon              | Toggle favorite. Fill = favorited      |
| "Expert Verified" badge | If item has been verified              |
| "For Sale" badge        | If item is also available for purchase |

#### Edge Cases

- **0 results:** → "No items found matching your filters" + "Try adjusting your filters" + suggested similar categories.
  - Sub-case: If query was specific (e.g., "underwater drone") → "No results for 'underwater drone'. Did you mean 'underwater camera'?"
- **Item becomes unavailable during browsing:** → If user clicks it → Item Details shows "Currently Unavailable" badge + next available date.
- **Slow network:** → Skeleton loading cards (grey animated placeholders) while items load.
- **Filter returns 1000+ items:** → Only first 200 loaded. "Showing top 200 results. Narrow your filters for better results."
- **Deep linking:** → All filter states are reflected in URL params so links can be shared.

---

### 3.3 Item Details Page

**Route:** `/items/:id`
**Top Bar:** Full navigation
**Type:** Public — visible to non-logged-in users

#### Sections (Top to Bottom)

**Image Gallery**

- Carousel of photos. Click/tap to open fullscreen lightbox with swipe navigation.
- Thumbnails below main image for quick navigation.

**Item Info Header**
| Field | Display |
|-------|---------|
| Title | Large, bold |
| Price | Tabbed: Per Day / Per Week / Per Month. Active tab highlighted |
| Deposit | "Deposit: 500 EGP (refundable)" |
| Cancellation Policy | Badge: `Flexible` (green) / `Moderate` (yellow) / `Strict` (red). Hover/click → tooltip with full policy rules |
| Condition | Badge: New / Like New / Good / Fair |
| Location | City + area + map pin icon |
| Listed Date | "Listed 3 days ago" |
| Views Counter | "Viewed 142 times" |

**Availability Calendar**

- Month view. Booked dates greyed/blocked. Available dates selectable.
- Legend: Green = Available, Grey = Booked, Blue = Selected.

**Owner Section**
| Element | Detail |
|---------|--------|
| Avatar + Name | Click → Owner's Profile Page |
| Owner Rating | "4.8 ★ as Owner (56 reviews)" |
| Verification Badges | ✓ Phone Verified, ✓ ID Verified |
| Member Since | "Member since Jan 2024" |
| Response Rate | "Responds within 2 hours" |
| **Chat Button** | "Message Owner" |

**Description & Specs**

- Full text (expandable if > 500 chars with "Read more").
- Spec table if applicable (Brand, Size, Weight, etc.)

**Expert Verification Section** _(if verified)_

- Badge: "✓ Expert Verified on [Date]"
- Expert's condition summary (collapsed, expandable)
- Expert's photos

**Reviews Section**

- Average rating (large): "4.7 ★ from 34 reviews"
- Rating breakdown bar chart (5★: 80%, 4★: 12%, etc.)
- Individual reviews: Reviewer name, avatar, stars, text, date.
- "Show All Reviews" button if > 5 reviews.

**Comments / Q&A Section**

- Post input field: "Ask a question about this item..."
- Threaded replies (max 3 levels). Each comment: avatar, name, text, timestamp, "Reply" button.
- Sorted by newest first. "Load more comments" if > 10.

**Similar Items Section**

- Horizontal scroll of 6-8 similar items (same category, similar price).

#### Action Buttons (Sticky Bottom Bar on Mobile)

| Button           | Condition                               | Action                         |
| ---------------- | --------------------------------------- | ------------------------------ |
| **Rent**         | Item status = `available`, user ≠ owner | → Rent Modal                   |
| **Buy**          | Sale enabled, item available            | → Checkout Modal (purchase)    |
| **Chat**         | User logged in, user ≠ owner            | → Chat Room with Owner         |
| **Favorite**     | User logged in                          | Toggle heart                   |
| **Share**        | Always                                  | Copy link / native share sheet |
| **Edit Listing** | User IS the owner                       | → Add/Edit Item Page           |
| **Report**       | User logged in, user ≠ owner            | → Report Modal                 |

#### Edge Cases (Full Depth)

- **Item currently rented:**
  - → "Currently Unavailable" badge replaces Rent button.
  - → Calendar shows when it's next available.
  - → "Notify Me" button appears → user gets notified when item becomes available.
- **Item pending approval:** → Only owner can see it. Shows "Pending Admin Review" banner. No public access.
- **Item suspended:** → 404 page for public. Owner sees "This item has been suspended by Admin. Reason: [reason]"
- **Item rejected:** → Only owner sees it. "Rejected: [reason]. [Edit & Resubmit]" banner.
- **User is the Owner:**
  - → Rent/Buy/Chat/Report buttons hidden.
  - → "Edit Listing" and "View Analytics" buttons shown.
  - → Owner sees their own item stats: views, favorites count, rental count.
- **User not logged in:**
  - → Rent/Buy/Chat buttons → clicking shows Login Modal: "Log in to rent this item."
  - → Favorite/Comment → same login prompt.
  - → Can still view all content, reviews, photos.
- **Item has no reviews:** → "No reviews yet. Be the first to rent this item!" placeholder.
- **Item has no photos:** → Should not happen (min 1 required at listing). But if data is corrupt → show placeholder image.
- **Owner account suspended:** → Item is hidden from search. Direct URL shows "This item is no longer available."

---

### 3.3.1 Rent Modal

**Type:** Modal overlay (triggered from Item Details)
**Background:** Item Details page dimmed behind

#### Contains

| Field                      | Detail                                            |
| -------------------------- | ------------------------------------------------- |
| Item title + thumbnail     | Context reminder                                  |
| Start Date Picker          | Calendar. Blocked dates greyed. Min = tomorrow    |
| End Date Picker            | Calendar. Min = start_date + 1 day                |
| **Calculated Summary**     |                                                   |
| — Rental Days              | Auto-calculated                                   |
| — Daily Rate               | × days                                            |
| — Weekly Rate (if cheaper) | System auto-suggests: "Save 15% with weekly rate" |
| — Deposit                  | Fixed by owner                                    |
| — Expert Fee (if checked)  | Displayed with payer info                         |
| — **Subtotal**             | Sum                                               |
| Expert Before Rental       | Checkbox + info tooltip                           |
| Expert After Rental        | Checkbox + info tooltip                           |

#### Edge Cases

- **Dates overlap with booking:** → Those dates greyed on calendar. If user manually types overlapping dates → error: "Item not available for [date] - [date]."
- **Start date is today:** → Blocked. "Earliest start date is tomorrow."
- **Duration > 90 days:** → Warning: "For long-term rentals, consider messaging the owner for a custom rate."
- **Owner has disabled Expert checks:** → Checkboxes hidden (MVP: always available).
- **Both Expert checkboxes checked:** → Fee display updates to show individual cost and payer info based on Hub Cost Sharing Rule.
- **Clicking "Proceed to Checkout" while not logged in:** → Login Modal appears first. After login → Rent Modal state is preserved.

---

### 3.3.2 Checkout Modal

**Type:** Modal overlay (triggered from Rent Modal or Buy)
**Background:** Previous modal/page dimmed

#### Contains

| Section                          | Detail                                                                             |
| -------------------------------- | ---------------------------------------------------------------------------------- |
| **Order Summary**                | Item name, dates, rental fee, deposit, expert fee, platform service fee, **TOTAL** |
| **Payment Method**               | Radio buttons: Vodafone Cash, Fawry, Paymob, Credit Card, Bank Transfer            |
| **Payment Details**              | Conditional fields based on method (card number, mobile number, etc.)              |
| **Cancellation Policy Reminder** | "This item has a [Flexible] cancellation policy. [View details]"                   |

#### States

| State          | Display                                                                                      |
| -------------- | -------------------------------------------------------------------------------------------- |
| **Default**    | Pay button active, all fields editable                                                       |
| **Processing** | Pay button disabled, spinner shown, "Processing your payment..." text                        |
| **Success**    | Green checkmark animation → "Payment successful!" → auto-redirect to Rental Details after 3s |
| **Failed**     | Red error → "Payment failed: [reason]" → Pay button re-enabled → user can retry              |

#### Edge Cases (Full Sub-Case Depth)

- **Item booked by another user during checkout:**
  - → System checks availability when Pay is clicked (not when modal opens).
  - → If dates now taken → "Sorry, this item was just booked for these dates. [Choose different dates]" → user returns to Rent Modal with calendar refreshed.
- **Payment fails:**
  - → "Payment failed. Please try again or choose a different payment method."
  - → Pay button re-enabled. User can retry unlimited times.
  - → If fails 3 times in a row → "Having trouble? [Contact Support]" link appears.
  - → Item lock remains active as long as modal is open (max 5 min).
- **User abandons checkout (closes modal/browser):**
  - → 5-minute lock expires → dates released automatically.
  - → No payment processed → no record created.
  - → If user returns → must restart from Rent Modal.
- **Double-click on Pay:**
  - → Button disabled on first click. Second click is no-op.
  - → Server-side idempotency key prevents duplicate charges.
- **Payment gateway timeout (>30 seconds):**
  - → "Payment is taking longer than expected. Please wait..." message.
  - → After 60s → "Payment timed out. Your card was NOT charged. [Try again]"
- **Network disconnection during payment:**
  - → When reconnected, system checks payment status.
  - → If payment went through → show success.
  - → If not → show failure, user can retry.
- **Insufficient balance (wallet/mobile money):**
  - → "Insufficient balance. Please top up your [Vodafone Cash] or choose another method."

---

### 3.3.3 Report Item Modal

**Type:** Modal (from Item Details — "Report" button)

#### Contains

| Field             | Detail                                                                                  |
| ----------------- | --------------------------------------------------------------------------------------- |
| Reason            | Dropdown: Fake listing, Inappropriate content, Stolen item, Wrong category, Spam, Other |
| Description       | Text area (optional but encouraged)                                                     |
| **Submit Report** | Button                                                                                  |

#### System Behavior

- Creates internal flag visible to Admin. Does NOT create a Support ticket.
- If same item reported 3+ times → auto-flagged for urgent Admin review.

---

### 3.4 Chat System

#### 3.4.1 Chat List Page

**Route:** `/chats`
**Top Bar:** Full navigation

#### Contains

| Element            | Detail                                                                                                         |
| ------------------ | -------------------------------------------------------------------------------------------------------------- |
| Search bar         | Filter conversations by user name                                                                              |
| Conversation cards | Avatar, Name, Last message preview (truncated 50 chars), Timestamp ("2m ago", "Yesterday"), Unread count badge |

#### Sorting

- Conversations with unread messages pinned to top.
- Then sorted by last message timestamp (newest first).

#### Edge Cases

- **No conversations:** → "No messages yet. Start by browsing items and messaging an owner!" + CTA → Browse Page.
- **Other user deleted their account:** → Conversation shows "[Deleted User]" with grey avatar. Messages preserved but user can't reply.
- **Other user suspended:** → Conversation shows name but "Reply" is disabled with tooltip: "This user's account is suspended."

#### 3.4.2 Chat Room Page

**Route:** `/chats/:chatId`
**Top Bar:** Full navigation. Sub-header: Other user's name, avatar, rating badge, "[View Item]" link (if conversation started from an item)

#### Contains

| Element          | Detail                                                                        |
| ---------------- | ----------------------------------------------------------------------------- |
| Message bubbles  | Left (other user), Right (you). Text + timestamp + read receipt (✓✓)          |
| Date separators  | "Today", "Yesterday", "March 15, 2026"                                        |
| Input area       | Text field + Send button + attachment icon (photos only, max 3, max 5MB each) |
| Typing indicator | "[User] is typing..."                                                         |

#### Edge Cases

- **Message fails to send:** → Red "!" icon on message. "Tap to retry" option.
- **Long message (>2000 chars):** → Blocked. "Message too long. Maximum 2000 characters."
- **Sending while offline:** → Message queued. Sent when connection restored. "Sending..." indicator shown.
- **User blocked by Admin during conversation:** → Input area disabled: "This conversation is no longer active."

---

### 3.5 My Rentals Page

**Route:** `/my-rentals`
**Top Bar:** Full navigation

#### Tabs

| Tab           | Filter                                          | Badge       |
| ------------- | ----------------------------------------------- | ----------- |
| **All**       | All rentals                                     | Total count |
| **Active**    | `active`, `extended`                            | Count       |
| **Upcoming**  | `requested`, `confirmed`, `paid`, `in_delivery` | Count       |
| **Completed** | `completed`                                     | —           |
| **Cancelled** | `cancelled`                                     | —           |
| **Disputed**  | `disputed`                                      | Count (red) |

#### Rental Card

| Element          | Detail                                                                                   |
| ---------------- | ---------------------------------------------------------------------------------------- |
| Item thumbnail   | Primary image                                                                            |
| Item title       | Click → Item Details                                                                     |
| Status badge     | Color-coded: green (active), blue (upcoming), grey (completed), red (disputed/cancelled) |
| Dates            | "Mar 15 → Mar 22, 2026"                                                                  |
| Role indicator   | "You are renting" or "You are lending"                                                   |
| Other party      | Name + rating                                                                            |
| Price            | Total rental fee                                                                         |
| **View Details** | → Rental Details Page                                                                    |

#### Empty States

- **No rentals at all:** "You haven't rented anything yet. Start browsing!" + CTA → Browse Page.
- **No active rentals:** "No active rentals right now."
- **No disputed:** "No disputes. Great!"

#### Edge Cases

- **User is both Owner and Renter:** → Both appear in the same list. Role indicator differentiates them.
- **Very old rentals (>1 year):** → Still visible in Completed tab. No archiving in MVP.
- **Rental status changes while viewing:** → Real-time update (or refresh on tab switch).

---

### 3.6 Rental Details Page

**Route:** `/rentals/:id`
**Top Bar:** Full navigation. Sub-header: "Rental #12345 — [Item Name]"
**Type:** Dynamic — content and actions change based on `status` and `role` (Owner vs Renter)

#### Sections

**Status Banner (Top)**

- Full-width colored banner showing current status + what happens next.
- Examples:
  - `requested`: "Waiting for owner to approve your request..."
  - `confirmed`: "Owner approved! Payment pending."
  - `active`: "Rental is active. Return by [date]."
  - `disputed`: "⚠ This rental is under dispute."

**Rental Info Card**
| Field | Detail |
|-------|--------|
| Item | Thumbnail + title (click → Item Details) |
| Other party | Avatar + name + rating (click → Profile) |
| Start Date | |
| End Date | (updates if extended) |
| Duration | "7 days" |
| Status | Badge |

**Payment Breakdown**
| Line | Amount |
|------|--------|
| Rental Fee | EGP X |
| Deposit | EGP Y — status: `held` / `returned` / `partially forfeited` / `fully forfeited` |
| Late Fee | EGP Z (only if overdue) |
| Expert Fee | EGP W — "Paid by: You / Owner / Split" |
| **Total** | |
| Payment Method | Vodafone Cash / etc. |
| Payment Status | `success` / `pending` / `failed` |

**Expert Evaluation Section** _(if hub was requested)_
| State | Display |
|-------|---------|
| Pending | "Expert inspection pending. Item is being evaluated." |
| Report submitted | Condition summary, photos, Expert name. Expandable full report |
| Renter decision needed | "Expert approved the item. Do you accept?" + **Accept** / **Reject** buttons |
| Rejected by Expert | "Item was rejected by Expert. Full refund issued." |

**Delivery Tracking Timeline**

- Visual vertical timeline with steps and timestamps:
  - `processing` → `shipped` → `at_hub` → `hub_to_renter` → `delivered` → (rental active) → `renter_returned` → `at_hub` → `hub_to_owner` → `owner_received`
- Each step has a confirmation button for the relevant party.

#### Dynamic Action Buttons

| Status        | Renter Sees                           | Owner Sees                                           |
| ------------- | ------------------------------------- | ---------------------------------------------------- |
| `requested`   | [Cancel Request]                      | [Approve] [Reject] [Chat]                            |
| `confirmed`   | [Cancel] [Pay Now]                    | [Cancel (penalty warning)] [Chat]                    |
| `paid`        | [Cancel (policy applies)]             | [Cancel (penalty warning)] [Confirm Shipment] [Chat] |
| `in_delivery` | [Confirm Receipt]                     | [Track Delivery] [Chat]                              |
| `active`      | [Extend Rental] [Report Issue] [Chat] | [Chat]                                               |
| `extended`    | [Extend Again] [Report Issue] [Chat]  | [Chat]                                               |
| `returned`    | "Waiting for owner confirmation"      | [Confirm Return] [Report Damage]                     |
| `completed`   | [Leave Review] [Download Receipt]     | [Leave Review] [Download Receipt]                    |
| `cancelled`   | [View Refund Status]                  | —                                                    |
| `disputed`    | [View Dispute] [Chat Support]         | [View Dispute] [Chat Support]                        |

#### Edge Cases (Full Sub-Cases)

- **Owner doesn't approve within 48h:**
  - → 24h: Reminder notification to Owner.
  - → 48h: Auto-rejected. Renter refunded 100%. Renter notified: "Owner didn't respond. Your rental was cancelled and refund issued."
- **Renter cancels after payment but before start:**
  - → Cancellation policy applied (see policy tables in ENTITY_INTERACTIONS.md).
  - → Refund amount calculated and shown in Cancel Modal BEFORE user confirms.
- **Owner cancels after confirming:**
  - → 100% refund to Renter.
  - → Owner sees: "You will receive a cancellation penalty. Search ranking reduced for 30 days."
  - → If Owner has 3+ cancellations in 30 days → system auto-suspends Owner's listings. Admin notified.
- **Late return detected:**
  - → Banner turns red: "⚠ This rental is overdue! Late fees are accumulating at EGP [X]/day."
  - → Late fee counter updates daily.
  - → Day 7+: "Download Legal PDF" button appears for Owner.
- **Both parties need to confirm return but disagree:**
  - → If Renter confirms return but Owner claims damage → Owner clicks "Report Damage" → Dispute Modal opens.
  - → If Owner confirms return but Renter claims they didn't return yet → edge case handled by delivery tracking evidence.

---

### 3.6.1 Extend Modal

**Type:** Modal (from Rental Details — "Extend Rental" button)

| Field            | Detail                                |
| ---------------- | ------------------------------------- |
| Current End Date | Display                               |
| New End Date     | Calendar picker. Blocked dates greyed |
| Extra Days       | Auto-calculated                       |
| Extra Cost       | Days × daily rate                     |
| **Send Request** | Submit                                |

#### Edge Cases

- **Extension conflicts with another booking:** → "Item is booked from [date]. Maximum extension is [X] days."
- **Owner doesn't respond for 48h:** → Auto-rejected. Renter notified.
- **Rental is overdue:** → Extension disabled: "Cannot extend an overdue rental."
- **Extension payment fails:** → Extension cancelled. Original dates remain.

---

### 3.6.2 Cancel Modal

**Type:** Modal (from Rental Details)

| Field                    | Detail                                             |
| ------------------------ | -------------------------------------------------- |
| Policy Tier              | Flexible / Moderate / Strict — with full rule text |
| Time Until Start         | "Rental starts in 3 days"                          |
| **Refund Breakdown**     |                                                    |
| — Rental Fee Refund      | Calculated per policy                              |
| — Deposit Refund         | Always 100%                                        |
| — Cancellation Penalty   | What user loses                                    |
| Warning text             | "This action cannot be undone."                    |
| **Confirm Cancellation** | Red button                                         |

#### Edge Cases

- **Dispute is active:** → Cancel button hidden. "Cannot cancel while dispute is active."
- **Rental already started:** → Shows: "Rental has already started. No rental fee refund. Your deposit will be returned after item return."
- **Payment still pending:** → Cancellation voids payment. No fee applied.

---

### 3.6.3 Dispute Modal

**Type:** Modal (from Rental Details — "Report Issue")

| Field              | Detail                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------- |
| Issue Type         | Dropdown: Item damaged, Not as described, Not returned, Late delivery, Payment issue, Other |
| Description        | Text area (required, min 50 chars)                                                          |
| Upload Evidence    | Photos/docs (max 5 files, max 5MB each)                                                     |
| **Submit Dispute** | Button                                                                                      |

#### System Behavior

- Creates Support ticket tagged `disputed`. Rental status → `disputed`.
- Both parties notified. Other party can also submit their evidence.

#### Edge Cases

- **Dispute on already-completed rental:** → Allowed within 7 days of completion. After 7 days → "Dispute window has closed."
- **Both parties open dispute on same rental:** → Merged into single Support ticket.

---

### 3.6.4 Review Modal

**Type:** Modal (from Rental Details after `completed`)

**Renter Reviews:**
| Field | Detail |
|-------|--------|
| Rate Item Condition | 1-5 stars (required) |
| Rate Owner Service | 1-5 stars (required) |
| Written Review | Text (optional, max 500 chars) |

**Owner Reviews:**
| Field | Detail |
|-------|--------|
| Rate Renter | 1-5 stars (required) |
| Written Review | Text (optional, max 500 chars) |

#### Edge Cases

- **Already reviewed:** → "You've already reviewed this rental." Button disabled.
- **Rental was disputed:** → Reviews allowed but "Disputed" badge shows on review.

---

### 3.6.5 Legal Evidence PDF

**Visibility:** Only on Rental Details when late fees > deposit amount.
**Button:** "Download Legal Evidence PDF"

**Contents:** Rental contract, Renter identity (name, national ID, phone), outstanding balance, dates, item description, digital timestamp.

---

### 3.7 Rental Requests Page (Owner)

**Route:** `/rental-requests`
**Top Bar:** Full navigation

#### Contains

- List of pending requests. Each card:
  - Renter name, avatar, rating, `id_verified` badge
  - Item name + thumbnail
  - Dates, price, deposit
  - Expert check requested? (badge)
  - **Approve** / **Reject** / **Chat** buttons

#### Edge Cases

- **Item already booked for overlapping dates:** → Remaining requests auto-rejected with: "Dates no longer available."
- **Renter's fraud score is flagged:** → Warning badge: "⚠ This user has been flagged for review."
- **No pending requests:** → "No rental requests right now."

---

### 3.8 Profile Page

**Route:** `/profile/:userId` (public) or `/profile` (own)
**Top Bar:** Full navigation

#### Public View

| Section             | Detail                            |
| ------------------- | --------------------------------- |
| Avatar + Name       | Large                             |
| Verification badges | ✓ Phone, ✓ ID                     |
| Owner Rating        | "4.8 ★ as Owner (56 reviews)"     |
| Renter Rating       | "4.5 ★ as Renter (23 reviews)"    |
| Member Since        | Date                              |
| Response Time       | "Usually responds within 2 hours" |
| Listed Items        | Grid of this user's active items  |
| Reviews Received    | Tabbed: "As Owner" / "As Renter"  |

#### Own Profile — Additional Actions

| Button           | Action              |
| ---------------- | ------------------- |
| Edit Profile     | → Settings Page     |
| Verify Identity  | → Verification Page |
| View My Listings | → My Listings Page  |

#### Edge Cases

- **User has no items:** → "No items listed yet" in items section.
- **User has no reviews:** → "No reviews yet. Start renting or listing to build your reputation!"
- **Suspended user's profile:** → 404 for other users. Own profile: "Your account is suspended."

---

### 3.9 Settings Page

**Route:** `/settings`
**Top Bar:** Full navigation

#### Sections

| Section            | Fields                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **Personal Info**  | First name, Last name, Profile photo (upload/change), City                                  |
| **Contact**        | Email (read-only + "Contact Support to change"), Phone (editable, triggers re-verification) |
| **Password**       | Current password, New password, Confirm. "Forgot password?" link                            |
| **Notifications**  | Toggles: Email notifications (on/off per type), Push notifications                          |
| **Privacy**        | Profile visibility: Public / Registered Users Only                                          |
| **Delete Account** | "Delete my account" (red, with confirmation modal)                                          |

#### Delete Account Modal

- Warning: "This will permanently delete your account, listings, and rental history. Active rentals must be completed first."
- If active rentals exist → "You have X active rentals. Complete them before deleting your account."
- Requires password re-entry to confirm.

---

### 3.10 Verification Page

**Route:** `/profile/verify`
**Top Bar:** Full navigation

#### Steps

| Step      | Detail                                                                                           |
| --------- | ------------------------------------------------------------------------------------------------ |
| **Phone** | Enter phone → "Send OTP" → Enter code → ✓ Verified                                               |
| **ID**    | Upload front photo → Upload back photo → "Submit for Review" → Status: Pending/Approved/Rejected |

#### Edge Cases

- **OTP expired:** → "Code expired. [Resend]" Max 3 resends per hour.
- **Wrong OTP 5 times:** → "Too many attempts. Try again in 15 minutes."
- **ID rejected:** → Reason shown + "Upload New Photos" button.
- **Already verified:** → Green checkmark. No action needed.

---

### 3.11 Wallet Page

**Route:** `/wallet`
**Top Bar:** Full navigation

#### Sections

| Section                 | Detail                                                                    |
| ----------------------- | ------------------------------------------------------------------------- |
| **Available Balance**   | Large number. "Earnings from completed rentals minus platform commission" |
| **Pending Balance**     | "From active rentals (released after completion)"                         |
| **Held Deposits**       | "Deposits held for your active rentals as a renter"                       |
| **Transaction History** | Scrollable list with filters                                              |

#### Transaction Card

| Field       | Detail                                                                     |
| ----------- | -------------------------------------------------------------------------- |
| Type icon   | ↓ earning (green), ↑ withdrawal (red), → deposit (blue), ← refund (orange) |
| Description | "Rental #123 — Surfboard"                                                  |
| Amount      | +/- EGP X                                                                  |
| Date        |                                                                            |
| Status      | `completed`, `pending`, `processing`, `failed`                             |

#### Withdraw Modal

| Field        | Detail                                      |
| ------------ | ------------------------------------------- |
| Amount       | Input. Min 50 EGP. Max = available balance  |
| Method       | Vodafone Cash (phone), Bank Transfer (IBAN) |
| **Withdraw** | Button                                      |

#### Edge Cases

- **Zero balance:** → Withdraw button disabled. "No funds available."
- **Amount below minimum:** → "Minimum withdrawal is 50 EGP."
- **Withdrawal fails:** → Money returns to wallet. User notified. Can retry.
- **Earnings clawed back (dispute reversal):** → Negative transaction shown: "Earnings reversed — Rental #123 dispute resolution."

---

### 3.12 My Listings Page

**Route:** `/my-listings`
**Top Bar:** Full navigation. "Add New Item" button prominently placed.

#### Tabs

| Tab           | Shows                                | Badge       |
| ------------- | ------------------------------------ | ----------- |
| **Pending**   | `pending_approval`                   | Count       |
| **Active**    | `available` or `rented`              | Count       |
| **Rejected**  | With rejection reason                | Count (red) |
| **Suspended** | Admin suspended                      | Count       |
| **Draft**     | Incomplete listings (if implemented) | —           |

#### Card Actions

| Button         | Condition         | Action                                      |
| -------------- | ----------------- | ------------------------------------------- |
| Edit           | Always            | → Add/Edit Item Page                        |
| Delete         | No active rentals | Remove listing                              |
| View Analytics | Active items      | Views, favorites, rentals count             |
| Resubmit       | Rejected items    | → Edit page, on save → goes back to pending |

#### Edge Cases

- **No listings:** → "You haven't listed any items yet. [List Your First Item]" CTA.
- **Item with active rental:** → Delete disabled with tooltip: "Complete active rentals first."
- **Rejected item:** → Red banner: "Rejected: [reason]. [Edit & Resubmit]"
- **Suspended item:** → Orange banner: "Suspended by Admin. Contact support for details."

---

### 3.13 Add/Edit Item Page

**Route:** `/items/new` or `/items/:id/edit`
**Top Bar:** Full navigation. Page title: "List a New Item" or "Edit [Item Name]"

#### Form (with inline validation)

| Field               | Required    | Validation                                                                 |
| ------------------- | ----------- | -------------------------------------------------------------------------- |
| Title               | Yes         | 5-200 chars                                                                |
| Description         | Yes         | 20-5000 chars                                                              |
| Category            | Yes         | Dropdown                                                                   |
| Subcategory         | Yes         | Dynamic based on category                                                  |
| Condition           | Yes         | Dropdown: New, Like New, Good, Fair                                        |
| Price/Day           | Yes         | > 0, decimal                                                               |
| Price/Week          | No          | Must be < 7 × Price/Day (or warning: "Weekly rate should be discounted")   |
| Price/Month         | No          | Must be < 30 × Price/Day                                                   |
| Deposit             | Yes         | > 0                                                                        |
| Cancellation Policy | Yes         | Radio: Flexible/Moderate/Strict with explanation panel                     |
| Photos              | Yes (min 1) | Max 10, max 5MB each, jpg/png/webp. Drag-and-drop reorder. First = primary |
| Location            | Yes         | City dropdown + area text field                                            |
| Available for Sale? | No          | Toggle. If yes → Sale Price field appears                                  |
| Sale Price          | Conditional | Required if sale toggle is on. > 0                                         |

#### Submit Behavior

| Scenario                                  | Result                                                                                                    |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| New item                                  | `status = pending_approval`. "Your item has been submitted for review. You'll be notified when approved." |
| Edit (minor: photos, typo)                | Stays `available`                                                                                         |
| Edit (major: price, description, deposit) | → `pending_approval` again. "Your changes are being reviewed."                                            |
| Edit rejected item                        | → `pending_approval`. "Resubmitted for review."                                                           |

#### Edge Cases

- **Unsaved changes + navigate away:** → Browser confirm: "You have unsaved changes. Leave page?"
- **Photo upload fails:** → "Failed to upload [filename]. [Retry]" Individual photo retry.
- **All photos deleted:** → Cannot submit. "At least 1 photo required."
- **Category changed:** → Subcategory resets. "Please select a new subcategory."

---

### 3.14 Favorites Page

**Route:** `/favorites`
**Top Bar:** Full navigation

#### Contains

- Grid of favorited items (same card format as Browse Page).
- Unfavorite button (heart) on each card.

#### Edge Cases

- **Empty:** "You haven't saved any favorites yet. [Browse Items]"
- **Favorited item deleted/suspended:** → Greyed card: "This item is no longer available." + Unfavorite button.
- **Favorited item price changed:** → Shows current price (not price at time of favoriting).

---

### 3.15 Notifications Page

**Route:** `/notifications`
**Top Bar:** Full navigation. "Mark All Read" button.
**Also available as:** Dropdown from bell icon (shows last 10)

#### Notification Item

| Element      | Detail                                                                   |
| ------------ | ------------------------------------------------------------------------ |
| Icon         | Type-specific (💬 message, 📦 rental, 💳 payment, ⚠ alert)               |
| Text         | "Your rental request for [Item] was approved by [Owner]"                 |
| Timestamp    | "2 hours ago"                                                            |
| Read/unread  | Unread = bold + blue dot                                                 |
| Click action | Navigate to relevant page (see redirect table in ENTITY_INTERACTIONS.md) |

#### Edge Cases

- **No notifications:** "No notifications yet. Start renting or listing to stay updated!"
- **100+ notifications:** Paginated. Load 20 at a time.
- **Notification about deleted item:** → Click → 404 page. Notification text still visible.

---

### 3.16 Support Page

**Route:** `/support`
**Top Bar:** Full navigation

#### Contains

| Section                  | Detail                                                               |
| ------------------------ | -------------------------------------------------------------------- |
| **FAQ / Help Center**    | Expandable categories: Renting, Listing, Payments, Account, Disputes |
| **My Tickets**           | List of user's tickets with status badges                            |
| **Create Ticket** button | → Create Ticket Modal                                                |

#### Ticket Detail View

- Conversation thread: user messages (right) + agent messages (left).
- Attached files inline.
- Status timeline: open → in_progress → resolved.
- **Rate Agent** button (after resolution): 1-5 stars.

#### Create Ticket Modal

| Field          | Detail                                          |
| -------------- | ----------------------------------------------- |
| Type           | Dropdown: Payment, Dispute, Account, Bug, Other |
| Related Rental | Optional dropdown of user's rentals             |
| Description    | Text area (min 20 chars)                        |
| Evidence       | File upload (max 5, max 5MB each)               |

#### Edge Cases

- **10+ open tickets:** → Warning: "You have many open tickets. Check existing ones first."
- **Ticket auto-resolved (5-day rule):** → Shows "Auto-Resolved (no response for 5 days)" badge. User can reply to reopen.
- **Support agent changed mid-ticket:** → Thread continues seamlessly. User sees "Agent changed to [New Agent]."

---

### 3.17 Terms of Service / Privacy Policy Pages

**Route:** `/terms` and `/privacy`
**Top Bar:** Full navigation
**Content:** Static legal text. Last updated date at top. Table of contents for navigation.

---

### 3.18 About Us Page

**Route:** `/about`
**Top Bar:** Full navigation
**Content:** Company mission, team, how it works (3-step: List → Rent → Return), trust & safety info.

---

## 4. SYSTEM LOGIC RULES

### 4.1 Item Lock During Checkout

- 5-minute soft lock when user enters Checkout Modal.
- Lock released on: payment success, payment failure, modal close, timeout.
- DB-level: `checkout_locks` table with `item_id`, `user_id`, `dates`, `expires_at`.
- Edge: If lock expires while user is still in modal → next "Pay" click checks lock → if expired → "Session expired. Please restart checkout."

### 4.2 Double Booking Prevention

- DB constraint: no overlapping `[start_date, end_date]` for same `item_id` where `status NOT IN (cancelled, disputed.resolved)`.
- Calendar reads from active rentals.
- Extension checks also validate against this constraint.

### 4.3 Two-Way Confirmation

- Both Owner and Renter must confirm handover AND return.
- 48h reminder → 72h Support notification → 96h auto-resolve (if no dispute).

### 4.4 Review Rules

- Only after `completed`. One per party per rental. Immutable after submission.
- User ratings are live averages recalculated on each new review.

### 4.5 Admin Approval Gate

- Every new listing = `pending_approval`. Only approved items searchable.
- Rejected items can be edited and resubmitted.

### 4.6 Expert Continuity Rule

- Same Expert for pre-check AND post-check. System enforces this.
- If Expert unavailable → Admin must manually reassign with continuity violation flag.

### 4.7 Auto-Resolve Tickets

- 5 days no user response → `resolved`. User reply → reopens.
- Escalated/disputed tickets excluded.

### 4.8 Legal PDF

- Generated only when late fees exceed deposit. Contains legally identifying information.

---

## 5. ADMIN PANEL

### 5.1 Admin Dashboard

**Route:** `/admin/dashboard`
**Top Bar:** Admin layout (Sidebar + Logo + Bell + Admin Avatar)

#### Contains

| Section                 | Detail                                                                                                                                     |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **KPI Cards**           | Revenue (day/week/month toggle), Active Rentals, New Users, Pending Listings (clickable → Item Mgmt), Open Disputes (clickable → Disputes) |
| **Revenue Chart**       | Line chart, daily/weekly/monthly toggle                                                                                                    |
| **Rentals by Category** | Bar chart                                                                                                                                  |
| **User Growth**         | Line chart                                                                                                                                 |
| **Activity Feed**       | Last 10: new listings, disputes opened, users flagged, Expert verdicts                                                                     |

#### Edge Cases

- **No data for time range:** → "No data. Try expanding the date range."
- **KPI click:** → Navigates to relevant management page filtered by the KPI context.

---

### 5.2 Item Management

**Route:** `/admin/items`
**Top Bar:** Admin layout

#### Tabs: Pending | Approved | Rejected | Suspended

**Pending Queue Card:**
| Field | Detail |
|-------|--------|
| Thumbnail, Title, Owner (click → User Details), Category, Price, Deposit, Submitted date | |
| **View Full** | Expand: description, all photos, specs |
| **Approve** | → `available`, Owner notified |
| **Reject** | → Reject Modal (reason required). Owner notified |
| **Suspend** | → Hidden from marketplace |
| **Remove** | Permanent delete (blocked if active rentals) |

**Reject Item Modal:** Reason text area (required) → Owner sees reason on My Listings.

#### Edge Cases

- **Active rentals on item:** → Suspend/Remove disabled: "Has active rentals."
- **Two Admins reviewing same item:** → "Being reviewed by [Admin]" lock indicator.
- **Item resubmitted 3+ times:** → Orange flag "Frequently resubmitted."
- **Bulk approval:** → Checkbox per item + "Approve Selected" button for standard items.
- **Admin doesn't review within 72h:** → System reminder notification to Admin.

---

### 5.3 User Management

**Route:** `/admin/users`
**Top Bar:** Admin layout

#### Main View: Searchable/filterable user table

| Column                                                                                  | Detail               |
| --------------------------------------------------------------------------------------- | -------------------- |
| Name, Email, Phone, Role, Status, Owner Rating, Renter Rating, Fraud Score, Joined Date |                      |
| **View Details**                                                                        | → `/admin/users/:id` |
| **Suspend / Unsuspend**                                                                 | Toggle               |

**User Details Page (`/admin/users/:id`):**
| Section | Detail |
|---------|--------|
| Profile info | Name, email, phone, city, ID images, avatar |
| Verification | Phone ✓/✗, ID ✓/✗/Pending |
| Ratings | Owner + Renter averages |
| Fraud Score | 0-1 with badge (safe/flagged/blocked) |
| Rental History | Table: item, dates, status, amount, role |
| Listed Items | Grid with statuses |
| Tickets | List of support tickets |
| Transactions | Payments, deposits, refunds |

**ID Verification Queue (`/admin/users/verification`):**

- Pending IDs: user name, front/back photos, submission date.
- **Approve** → `id_verified = true`. **Reject** → reason required, user notified.

#### Edge Cases

- **Suspending user with active rentals:** → Warning: "This user has X active rentals. Suspending will NOT auto-cancel them."
  - Sub-case: Admin must decide per rental: cancel with refund, or let it complete.
- **Viewing national ID:** → Action logged for security audit.
- **User's fraud score changed while Admin is viewing:** → Score refreshes on page reload.

---

### 5.4 Dispute Resolution

**Route:** `/admin/disputes`
**Top Bar:** Admin layout

#### Dispute Card

| Field                                                                                                                                                                          | Detail |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ |
| Ticket ID, Renter (click → User Details), Owner (click → User Details), Item (click → Item Details), Dispute Type, Deposit amount, Evidence files, Expert Report (if Hub used) |        |

#### Actions

| Button                | Action                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------- |
| **View Evidence**     | Expand all photos, docs, Expert reports, chat logs                                                |
| **Forfeit Partial**   | → Forfeiture Modal: enter amount (≤ deposit), reason (required). Auto-calculates refund remainder |
| **Forfeit Full**      | 100% deposit → Owner wallet                                                                       |
| **Additional Charge** | For lost items where deposit < value. Flags debt on Renter                                        |
| **Refund Renter**     | Override for emergencies                                                                          |
| **Close Dispute**     | Both parties notified                                                                             |
| **Admin Note**        | Internal note, staff-only                                                                         |

#### Edge Cases

- **Deposit already returned:** → Forfeiture buttons disabled.
- **Dispute > 30 days old:** → Warning banner.
- **Admin reversal needed after 48h:** → "Contact Super Admin for override."
- **Both parties submitted evidence:** → Side-by-side comparison view.
- **Expert report contradicts Owner claim:** → Admin sees both with highlight.
- **All actions audit-logged:** who, when, what, amount.

---

### 5.5 Admin Support

**Route:** `/admin/support`
**Top Bar:** Admin layout

- View ALL tickets (not just escalated). Filter by status, agent, type, escalation flag.
- **Actions:** Reassign agent, Override status, Force-close, Escalate to Super Admin.
- **Edge Case:** Admin force-closes a ticket → user can reopen by replying.

---

### 5.6 Analytics & Gap Analysis

**Route:** `/admin/analytics`
**Top Bar:** Admin layout

**Gap Analysis Tab:**
| Column | Detail |
|--------|--------|
| Search Term | What users searched |
| Search Count | How many times |
| Available Items | Items matching this term |
| Gap Score | searches ÷ available (higher = bigger gap) |
| City Breakdown | Which cities have the gap |

- Click term → see search log distribution over time.
- **Export CSV** button.

**Fraud Panel Tab:**

- Flagged Users table: Name, Score, Risk Level, Last Activity.
- **Block User** | **Whitelist** | **Adjust Threshold** (shows impact preview: "X additional users affected")
- **Edge Case:** Lowering threshold → confirmation: "This will flag X additional users. Proceed?"

---

### 5.7 Expert Performance

**Route:** `/admin/experts`
**Top Bar:** Admin layout

| Column                                                                                                                                       | Detail |
| -------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| Expert Name (click → User Details), Items Today, Daily Target, Status (✅/⚠️/❌), Weekly Total, Monthly Total, Avg Check Time, Accuracy Rate |        |

**Assign Item Modal:** Search item/rental ID, Verification type (before/after), Priority (normal/urgent), Notes.

#### Edge Cases

- **Expert has 15+ items:** → "Heavy Workload" warning.
- **Item already assigned:** → "Already assigned to [Expert]."
- **Expert hasn't started urgent within 4h:** → Admin notified.

---

### 5.8 System Settings

**Route:** `/admin/settings`
**Top Bar:** Admin layout

| Setting                                 | Editable By      |
| --------------------------------------- | ---------------- |
| Platform Commission %                   | Super Admin only |
| Default Cancellation Policy             | Admin            |
| Expert Evaluation Fee                   | Admin            |
| Auto-Resolve Days (default: 5)          | Admin            |
| Fraud Threshold (default: 0.8)          | Admin            |
| Late Fee Rate (default: 150%)           | Admin            |
| Checkout Lock Duration (default: 5 min) | Admin            |

- **Save Changes** → updates `system_settings` table.
- **View Change Log** → audit trail with timestamp + who changed it.

---

### 5.9 Admin Notifications

| Event                     | Description                     |
| ------------------------- | ------------------------------- |
| `new_listing_pending`     | New item awaiting approval      |
| `dispute_escalated`       | Support escalated a ticket      |
| `fraud_alert`             | User flagged by AI              |
| `expert_target_missed`    | Expert didn't meet daily target |
| `id_verification_pending` | New ID upload                   |
| `system_setting_changed`  | Another Admin changed settings  |

---

## 6. EXPERT PANEL

### 6.1 Expert Dashboard

**Route:** `/expert/dashboard`
**Top Bar:** Expert layout (Sidebar + Logo + Bell + Expert Avatar)

| Section              | Detail                                                                         |
| -------------------- | ------------------------------------------------------------------------------ |
| **Today's Progress** | "Checked: X / Target: Y" + progress bar                                        |
| **Urgent Queue**     | Items marked urgent (highlighted red)                                          |
| **Upcoming Returns** | Items this Expert pre-checked that are due for return (post-check needed soon) |

---

### 6.2 Assigned Items Queue

**Route:** `/expert/queue`
**Top Bar:** Expert layout

**Tabs:** Pre-Rental | Post-Rental | All

**Queue Card:**
| Field | Detail |
|-------|--------|
| Item thumbnail + title, Owner name, Renter name, Dates, Type badge (`before_rent`/`after_return`), Priority, Assigned date, **Start Inspection** button | |

- Sorted: Urgent first, then oldest assigned date.

#### Edge Cases

- **Duplicate assignment:** → "Already Verified" badge, view-only mode.
- **Rental cancelled after assignment:** → "Cancelled" badge, removed from active queue, kept in history.
- **Expert's own item assigned:** → System blocks. "Cannot verify your own items."

---

### 6.3 Pre-Rental Verification Form

**Route:** `/expert/verify/:rentalId/before`
**Top Bar:** Expert layout. Sub-header: "Pre-Rental Inspection — [Item Name]"

**Header:** Item details, Owner info, Renter info, Rental dates.

| Field                | Required    | Detail                                              |
| -------------------- | ----------- | --------------------------------------------------- |
| Overall Condition    | Yes         | Dropdown: Excellent, Good, Fair, Poor, Unacceptable |
| Detailed Description | Yes         | Rich text (scratches, wear, functionality)          |
| Photos               | Yes (min 3) | Multi-angle upload with captions                    |
| Estimated Deposit    | Conditional | If Owner didn't set one. Can confirm/adjust Owner's |
| Functional Test      | Yes         | Yes / No / N/A                                      |
| Notes for Renter     | Optional    | Handling instructions                               |

**Verdict:** **Approve** → Renter notified, can Accept/Reject. **Reject** → Rejection Modal (reason + fraud flag checkbox).

#### Edge Cases

- **Unsaved changes + navigate away:** → "You have unsaved changes" browser warning.
- **Accidental approve:** → Can contact Admin to override within 2 hours.
- **Item not received at Hub within 48h:** → "Not Received" status → auto-creates Support ticket.
- **Internet lost during submit:** → Draft preserved locally. Retry on reconnect.

---

### 6.4 Post-Rental Verification Form

**Route:** `/expert/verify/:rentalId/after`
**Top Bar:** Expert layout. Sub-header: "Post-Rental Inspection — [Item Name]"

**Header:** Same as pre-rental + **Pre-Rental Report** (read-only, for comparison).

| Field               | Required    | Detail                                                                         |
| ------------------- | ----------- | ------------------------------------------------------------------------------ |
| Current Condition   | Yes         | Dropdown: Same as before, Minor wear, Damaged, Severely Damaged, Missing Parts |
| Description         | Yes         | What changed since pre-rental                                                  |
| Comparison Photos   | Yes (min 3) | Side-by-side with pre-rental photos                                            |
| Damage Assessment   | Conditional | If damage: description + repair cost estimate                                  |
| Is Renter Liable?   | Yes         | Yes / No / Partially                                                           |
| Recommended Penalty | Conditional | Suggested deduction from deposit                                               |

**Verdict:** **No Damage** → deposit refund. **Renter Liable** → Admin reviews. **Normal Wear** → not Renter's fault.

#### Edge Cases

- **Continuity Rule violated (different Expert):** → System error: "Continuity Rule Violated. Contact Admin."
  - Sub-case: Admin must manually reassign and acknowledge the violation in the record.
- **Post-check not done within 7 days:** → Admin alerted.
- **Expert and Owner disagree:** → Admin sees both assessments side-by-side.
- **Expert's verdict is a recommendation:** → Admin makes final call on deposit.

---

### 6.5 History Page

**Route:** `/expert/history`
**Top Bar:** Expert layout

- Filterable table: Item, Rental ID, Type (before/after), Date, Verdict, Condition.
- Click → read-only report view.

---

### 6.6 Performance Dashboard

**Route:** `/expert/performance`
**Top Bar:** Expert layout

| Section        | Detail                            |
| -------------- | --------------------------------- |
| Today          | Progress bar + count vs target    |
| This Week      | Bar chart by day                  |
| This Month     | Trend line                        |
| Avg Check Time | Minutes per inspection            |
| Accuracy Rate  | % matching Admin's final decision |

- **Edge:** Target not met by 4 PM → reminder notification. Data resets daily at midnight.

---

### 6.7 Expert Notifications

| Event                | Description                                 |
| -------------------- | ------------------------------------------- |
| `new_assignment`     | New item assigned                           |
| `urgent_assignment`  | Urgent priority                             |
| `post_return_ready`  | Pre-checked item returned, needs post-check |
| `target_reminder`    | 4 PM daily if target not met                |
| `verdict_overridden` | Admin overrode this Expert's recommendation |

---

## 7. SUPPORT AGENT PANEL

### 7.1 Support Dashboard

**Route:** `/support-panel/dashboard`
**Top Bar:** Support layout (Sidebar + Logo + Bell + Agent Avatar)

| Section           | Detail                               |
| ----------------- | ------------------------------------ |
| My Open Tickets   | Count (click → filtered ticket list) |
| Unassigned Pool   | Count (click → unassigned list)      |
| Resolved Today    | Count + mini chart                   |
| Avg Response Time | This agent's metric                  |
| My Rating         | 1-5 stars average                    |

---

### 7.2 Ticket Dashboard

**Route:** `/support-panel/tickets`
**Top Bar:** Support layout

**Tabs:** My Tickets | Unassigned | All

**Ticket Card:** Ticket ID, User name, Type, Status badge, Created date, Last reply, Priority, Escalation flag (⬆).

- **Self-Assign** (unassigned) | **Open Ticket** (→ detail page).

---

### 7.3 Ticket Detail Page

**Route:** `/support-panel/tickets/:ticketId`
**Top Bar:** Support layout. Sub-header: "Ticket #[ID] — [Type]"

**Header:** User info (name, email, ratings, verification — click → read-only profile), Related Rental/Item (if linked), Status timeline.

**Conversation Thread:** User messages (left), Agent messages (right), timestamps, read indicators, attached files inline.

**Internal Notes Section:** Agent/Admin only. Not visible to user.

**Agent Actions:**
| Button | Action |
|--------|--------|
| Reply | Send to user |
| Internal Note | Staff-only note |
| Change Status | open → in_progress → resolved (cannot skip) |
| Escalate | → Escalation Modal (reason + suggested action + evidence) |
| Close | Only after resolved + user rated (or 5-day auto-resolve) |

#### Edge Cases

- **Auto-resolved ticket:** → "Auto-Resolved" badge. If user replies → reopens.
- **Related rental has Hub eval:** → Link to Expert report.
- **Closed ticket:** → Reply disabled. Must reopen first.
- **Agent reassigned mid-ticket:** → New agent sees full history + notes.
- **Agent hasn't replied in 4h:** → Priority auto-escalates to "High."
- **Agent cannot:** modify financial data, issue refunds, change fraud flags, suspend users.

---

### 7.4 Agent Performance

**Route:** `/support-panel/performance`
**Top Bar:** Support layout

| Section             | Detail                                       |
| ------------------- | -------------------------------------------- |
| My Rating           | Average + count. Bar chart breakdown (1★-5★) |
| Tickets Resolved    | Today / Week / Month                         |
| Avg Response Time   | First reply (hours)                          |
| Avg Resolution Time | Open → Resolved (hours)                      |
| Escalation Rate     | % escalated vs resolved independently        |

- **Edge:** Fewer than 5 ratings → "Not enough data yet."

---

### 7.5 Support Notifications

| Event                 | Description                   |
| --------------------- | ----------------------------- |
| `new_ticket_assigned` | New ticket assigned           |
| `ticket_reply`        | User replied                  |
| `escalation_response` | Admin responded to escalation |
| `auto_resolved`       | 5-day auto-resolve            |
| `new_rating`          | User rated agent              |
| `ticket_reassigned`   | Admin reassigned ticket       |

---

## 8. SUPER ADMIN PANEL

### 8.1 Super Admin Dashboard

**Route:** `/super-admin/dashboard`
**Top Bar:** Super Admin layout (Admin sidebar + extra items + "Super Admin" role badge)

- Everything from Admin Dashboard (5.1) PLUS:

| Section         | Detail                                                   |
| --------------- | -------------------------------------------------------- |
| Staff Overview  | Total Admins/Support/Experts — active vs suspended       |
| System Health   | API response times, DB stats, background job status      |
| Critical Alerts | Disputes > 7 days, Experts missing targets, fraud spikes |

---

### 8.2 Staff Management

**Route:** `/super-admin/staff`
**Top Bar:** Super Admin layout (EXCLUSIVE to Super Admin)

**Tabs:** Admins | Support Agents | Experts

**Staff Table:** Name, Email, Role, Status, Created Date, Created By, Last Login, Performance Score.

**Actions:** Create (→ modal), Suspend, Unsuspend, Change Role, Delete (if no active assignments), View Activity Log.

**Create Staff Modal:** First name, Last name, Email (unique), Temp password (auto or manual), Role dropdown, City/Branch (for Experts).

#### Edge Cases

- **Last Super Admin:** → Cannot delete own account. "Cannot remove the last Super Admin."
- **Self-demotion:** → Blocked. "Cannot change your own role."
- **Deleted Expert with assignments:** → Auto-reassign to another Expert.
- **All staff actions audit-logged.**

---

### 8.3 Super Admin Settings

**Route:** `/super-admin/settings`
**Top Bar:** Super Admin layout

- Everything from Admin Settings (5.8) PLUS:

| Setting               | Detail                                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Platform Commission % | Default 15%. **Impact Preview**: "Changing to X% affects Y active rentals. Apply to new rentals only? Or retroactive?" → Always new rentals only |
| Feature Toggles       | Enable/disable: Buying, Hub Evaluations, AI Recommendations, Chat                                                                                |
| Maintenance Mode      | Full platform offline. "Under Maintenance" shown to all users                                                                                    |
| Audit Log Viewer      | All setting changes, staff actions, financial overrides. Exportable CSV                                                                          |

#### Edge Cases

- **Commission change:** → Locked at creation time for existing rentals. Only affects new ones.
- **Maintenance mode during active checkouts:** → Those checkouts auto-cancelled with full refund.
- **Disabling "Buying" feature:** → All "Buy" buttons disappear. Existing completed purchases unaffected.

---

### 8.4 Override & Emergency Actions

**Route:** `/super-admin/overrides`
**Top Bar:** Super Admin layout

| Action                     | Detail                                            |
| -------------------------- | ------------------------------------------------- |
| Reverse Deposit Forfeiture | Undo Admin's decision. Clawback from Owner wallet |
| Unsuspend User             | Override Admin's suspension                       |
| Reinstate Item             | Restore removed/suspended item                    |
| Force-Close Dispute        | Custom resolution, bypass normal flow             |
| Take Over Dispute          | Remove from assigned Admin                        |

#### Edge Cases

- **Every override permanently logged:** who, when, what changed, old value, new value.
- **Override another Super Admin's override:** → Requires justification note.
- **Clawback from empty Owner wallet:** → Owner's balance goes negative. Flagged for reconciliation.

---

### 8.5 Super Admin Notifications

| Event                          | Description            |
| ------------------------------ | ---------------------- |
| `staff_account_created`        | By another Super Admin |
| `commission_changed`           | Rate modified          |
| `critical_dispute_7d`          | Unresolved 7+ days     |
| `admin_action_override_needed` | Flagged for review     |
| `system_setting_changed`       | Any setting modified   |
| `maintenance_mode_toggled`     | On/Off                 |

---

## 9. COMPLETE MODALS LIST (All Roles)

| #   | Modal                   | Panel       | Triggered From             | Purpose                               |
| --- | ----------------------- | ----------- | -------------------------- | ------------------------------------- |
| 1   | Rent Modal              | User        | Item Details               | Select dates, expert options          |
| 2   | Checkout Modal          | User        | Rent Modal / Buy           | Payment processing                    |
| 3   | Cancel Modal            | User        | Rental Details             | Cancellation + policy display         |
| 4   | Extend Modal            | User        | Rental Details             | Request extra days                    |
| 5   | Review Modal            | User        | Rental Details (completed) | Rate item/owner/renter                |
| 6   | Dispute Modal           | User        | Rental Details             | Report issue + evidence               |
| 7   | Report Item Modal       | User        | Item Details               | Flag suspicious listing               |
| 8   | Create Ticket Modal     | User        | Support Page               | Submit support request                |
| 9   | Withdraw Modal          | User        | Wallet                     | Withdraw earnings                     |
| 10  | Delete Account Modal    | User        | Settings                   | Permanent deletion                    |
| 11  | Login/Register Modal    | User        | Any protected action       | Auth gate (if using modal-based auth) |
| 12  | Reject Item Modal       | Admin       | Item Management            | Reject listing with reason            |
| 13  | Forfeiture Modal        | Admin       | Disputes                   | Partial/full deposit forfeiture       |
| 14  | Assign Item Modal       | Admin       | Expert Management          | Assign item for verification          |
| 15  | Rejection Confirm Modal | Expert      | Verification Form          | Reject item + optional fraud flag     |
| 16  | Escalation Modal        | Support     | Ticket Detail              | Escalate to Admin                     |
| 17  | Create Staff Modal      | Super Admin | Staff Management           | Create staff account                  |

---

## 10. FINAL COVERAGE CHECKLIST

### Pages Count

| Panel       | Pages                                                                                                                                                                                                             |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Auth        | 5 (Login, Register, Forgot Password, Reset Password, Email Verify)                                                                                                                                                |
| Error       | 4 (404, 403, 500, Maintenance)                                                                                                                                                                                    |
| User App    | 18 (Home, Browse, Item Details, Chat List, Chat Room, My Rentals, Rental Details, Rental Requests, Profile, Settings, Verification, Wallet, My Listings, Add/Edit Item, Favorites, Notifications, Support, About) |
| Static      | 2 (Terms, Privacy)                                                                                                                                                                                                |
| Admin       | 9 (Dashboard, Items, Users, User Detail, ID Queue, Disputes, Support, Analytics, Experts, Settings)                                                                                                               |
| Expert      | 6 (Dashboard, Queue, Pre-Verify, Post-Verify, History, Performance)                                                                                                                                               |
| Support     | 4 (Dashboard, Tickets, Ticket Detail, Performance)                                                                                                                                                                |
| Super Admin | 4 (Dashboard, Staff, Settings, Overrides)                                                                                                                                                                         |
| **Total**   | **52+ distinct pages**                                                                                                                                                                                            |

### Feature Checklist

- [x] Every page has route, top bar spec, content sections, and actions
- [x] All user roles covered (User, Owner, Renter, Buyer, Seller)
- [x] All staff roles fully detailed (Admin, Support, Expert, Super Admin)
- [x] Every edge case explained to sub-case depth
- [x] Empty states for every page
- [x] Error states for every action
- [x] Auth flow complete (login, register, verify, reset, session)
- [x] Global navigation specified per role
- [x] State machine with dynamic action buttons per status
- [x] Notification system per role with redirect logic
- [x] Expert continuity rule + pre/post verification forms
- [x] Admin approval gate for listings
- [x] Dual rating system (owner + renter)
- [x] Support agent rating system
- [x] 3-tier cancellation policies
- [x] Real-time chat + typing indicators
- [x] Threaded comments (3 levels max)
- [x] Favorites feeding recommendations
- [x] Search logging for gap analysis
- [x] Legal PDF for extreme late returns
- [x] Fraud detection with threshold controls
- [x] Payment flow with all failure sub-cases
- [x] Double booking prevention (soft lock + DB constraint)
- [x] Two-way confirmation (handover + return)
- [x] Auto-resolve stale tickets (5-day rule)
- [x] Super Admin override + full audit trail
- [x] Staff provisioning (CRUD)
- [x] System settings with impact preview
- [x] 17 modals across all roles
- [x] 52+ pages total
- [x] Ready for frontend + backend implementation ✅

---

## 11. PAGE → API MATRIX (Merged from PAGE_API_MATRIX)

> This section maps **every frontend page** to the API endpoints it consumes. All endpoints are prefixed with `/api/v1`. Real-time features use WebSocket (Section 12).

---

### 11.1 PUBLIC PAGES (No Auth)

| Page                              | APIs Consumed                                                                                        | Notes                                               |
| --------------------------------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| **Login**                         | `POST /auth/login`                                                                                   | Returns JWT (access + refresh)                      |
| **Register**                      | `POST /auth/register`                                                                                | Creates user, sends verification email              |
| **Verify Email**                  | `POST /auth/verify-email`                                                                            | Confirms email via token                            |
| **Forgot Password**               | `POST /auth/forgot-password`                                                                         | Always returns success (prevents email enumeration) |
| **Reset Password**                | `POST /auth/reset-password`                                                                          | Validates token, updates password                   |
| **Home Page**                     | `GET /items?featured=true`, `GET /recommendations` (if logged in)                                    | Recommendations require auth                        |
| **Browse Page**                   | `GET /items?category=&city=&minPrice=&maxPrice=&type=&sort=&page=`, `GET /search?q=&category=&city=` | Search logs query for gap analysis                  |
| **Item Details**                  | `GET /items/:id`, `GET /items/:id/reviews`, `GET /items/:id/comments`                                | view logged to `user_interactions` if authed        |
| **About Page**                    | None (static)                                                                                        |                                                     |
| **Terms / Privacy**               | None (static)                                                                                        |                                                     |
| **404 / 403 / 500 / Maintenance** | None                                                                                                 | Maintenance flag from `system_settings`             |

---

### 11.2 USER PAGES (Auth: user)

| Page                | APIs Consumed                                                                                                                                                                                                    | Auth       | Notes                                              |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------------------- |
| **Profile**         | `GET /auth/me`, `PUT /auth/me`                                                                                                                                                                                   | ✅         |                                                    |
| **Settings**        | `GET /auth/me`, `PUT /auth/me`, `POST /auth/phone/send-otp`, `POST /auth/phone/verify-otp`                                                                                                                       | ✅         | Phone OTP simulated                                |
| **Verification**    | `POST /auth/id-verification`, `GET /auth/id-verification`                                                                                                                                                        | ✅         | ID front/back upload                               |
| **Favorites**       | `GET /users/me/favorites`, `DELETE /items/:id/favorite`                                                                                                                                                          | ✅         |                                                    |
| **My Listings**     | `GET /items?owner=me`                                                                                                                                                                                            | ✅         | Includes pending/approved/rejected                 |
| **Add Item**        | `POST /items`                                                                                                                                                                                                    | ✅         | Status → `pending_approval`                        |
| **Edit Item**       | `GET /items/:id`, `PUT /items/:id`                                                                                                                                                                               | ✅ (owner) | Major edits → re-review                            |
| **My Rentals**      | `GET /rentals?status=&page=&limit=`                                                                                                                                                                              | ✅         | Tabs: as renter / as owner                         |
| **Rental Requests** | `GET /rentals?status=requested&role=owner`                                                                                                                                                                       | ✅         | Incoming requests for owner                        |
| **Rental Details**  | `GET /rentals/:id`, `PUT /rentals/:id/confirm` (owner), `PUT /rentals/:id/cancel` (renter), `PUT /rentals/:id/complete` (owner), `PUT /rentals/:id/evaluation-decision` (renter), `GET /items/:id/verifications` | ✅         | Dynamic actions per rental status                  |
| **Wallet**          | `GET /auth/me` (balance derived), `GET /rentals?status=completed&role=owner`                                                                                                                                     | ✅         | MVP: derived from completed rentals                |
| **Chat List**       | `GET /chats`                                                                                                                                                                                                     | ✅         | WebSocket: `unread_count_update`                   |
| **Chat Room**       | `GET /chats/:id/messages`, `POST /chats/:id/messages`                                                                                                                                                            | ✅         | WebSocket: `new_message`, `typing`, `message_read` |
| **Notifications**   | `GET /notifications`, `PUT /notifications/:id/read`, `PUT /notifications/read-all`                                                                                                                               | ✅         | WebSocket: `new_notification`                      |
| **Support Page**    | `POST /support/tickets`, `GET /support/tickets`, `POST /support/tickets/:id/messages`, `POST /support/tickets/:id/rate`                                                                                          | ✅         |                                                    |

#### User Modals

| Modal                    | APIs Consumed                                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| **Rent Modal**           | `POST /rentals` (validates availability, calculates price, checks fraud)                                            |
| **Checkout Modal**       | `POST /payments` (simulated gateway)                                                                                |
| **Cancel Modal**         | `PUT /rentals/:id/cancel` (shows policy: flexible/moderate/strict)                                                  |
| **Extend Modal**         | `POST /rentals/:id/extend`                                                                                          |
| **Review Modal**         | `POST /rentals/:id/review` (rating 1-5 + comment)                                                                   |
| **Dispute Modal**        | `POST /support/tickets` (type='dispute', with evidence)                                                             |
| **Report Item Modal**    | `POST /items/:id/report`                                                                                            |
| **Create Ticket Modal**  | `POST /support/tickets`                                                                                             |
| **Withdraw Modal**       | MVP: display-only                                                                                                   |
| **Delete Account Modal** | `DELETE /auth/me` (soft delete)                                                                                     |
| **Item Details Actions** | `POST /items/:id/favorite`, `DELETE /items/:id/favorite`, `POST /items/:id/comments`, `POST /chats` (contact owner) |

---

### 11.3 EXPERT PAGES (Auth: expert)

| Page                         | APIs Consumed                                                                                                                                        | Notes                              |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **Expert Dashboard**         | `GET /expert/assigned?status=pending`, computed daily progress                                                                                       | Today's count vs target            |
| **Assigned Queue**           | `GET /expert/assigned`                                                                                                                               | Tabs: Pre-Rental / Post-Rental     |
| **Pre-Rental Verification**  | `GET /rentals/:id`, `GET /items/:id`, `POST /items/:id/verify` (checkType='before_rent')                                                             | Min 3 photos, condition dropdown   |
| **Post-Rental Verification** | `GET /rentals/:id`, `GET /items/:id`, `GET /items/:id/verifications` (pre-check for comparison), `POST /items/:id/verify` (checkType='after_return') | Side-by-side with pre-check photos |
| **Verification History**     | `GET /items/:id/verifications?expertId=me`                                                                                                           | Read-only past reports             |
| **Performance Dashboard**    | `GET /expert/assigned` (computed metrics)                                                                                                            | Daily/weekly/monthly stats         |

---

### 11.4 SUPPORT AGENT PAGES (Auth: support)

| Page                  | APIs Consumed                                                                                       | Notes                                      |
| --------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| **Support Dashboard** | `GET /support/tickets?agent=me`, computed metrics                                                   | Open/unassigned/resolved counts            |
| **Ticket Dashboard**  | `GET /support/tickets` (ALL tickets), filter by status/type/agent                                   | Tabs: My / Unassigned / All                |
| **Ticket Detail**     | `GET /support/tickets/:id`, `POST /support/tickets/:id/messages`, `PUT /support/tickets/:id/status` | Internal notes (staff-only flag)           |
| **Agent Performance** | Computed from ticket metrics                                                                        | Rating, avg response time, escalation rate |

---

### 11.5 ADMIN PAGES (Auth: admin, super_admin)

| Page                      | APIs Consumed                                                                                                                    | Notes                                     |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| **Admin Dashboard**       | `GET /admin/kpis/latest`, `GET /admin/kpis?period=`                                                                              | KPI cards, charts                         |
| **Item Management**       | `GET /admin/items/pending`, `PUT /admin/items/:id/approve`, `PUT /admin/items/:id/reject`, `PUT /items/:id`, `DELETE /items/:id` | Tabs: Pending/Approved/Rejected/Suspended |
| **User Management**       | `GET /admin/users?page=&limit=`, `PUT /admin/users/:id/status`                                                                   | Searchable/filterable                     |
| **User Details**          | `GET /admin/users/:id` (extended profile + rental history + fraud score)                                                         |                                           |
| **ID Verification Queue** | `GET /admin/id-verifications/pending`, `PUT /admin/id-verifications/:id`                                                         | Approve/Reject with reason                |
| **Dispute Resolution**    | `GET /admin/disputes`, `PUT /admin/disputes/:id/resolve`                                                                         | Evidence view, forfeiture controls        |
| **Admin Support**         | `GET /support/tickets` (all), `PUT /support/tickets/:id/status`, `POST /support/tickets/:id/messages`                            | Reassign, override, escalate              |
| **Analytics (Gap)**       | `GET /admin/gap?period=&limit=`                                                                                                  | Gap score, CSV export                     |
| **Analytics (Fraud)**     | `GET /admin/fraud?decision=&minRisk=`, `PUT /admin/fraud/:userId/whitelist`                                                      | Block/Whitelist/Adjust threshold          |
| **Expert Management**     | `GET /admin/expert-performance`, `POST /admin/expert-assignments`                                                                | Assign items, view performance            |
| **System Settings**       | `GET /admin/settings`, `PUT /admin/settings/:key`                                                                                | Change log via `GET /admin/audit-logs`    |

#### Admin Modals

| Modal                 | APIs Consumed                                    |
| --------------------- | ------------------------------------------------ |
| **Reject Item Modal** | `PUT /admin/items/:id/reject` (reason required)  |
| **Forfeiture Modal**  | `PUT /admin/disputes/:id/resolve` (partial/full) |
| **Assign Item Modal** | `POST /admin/expert-assignments`                 |

---

### 11.6 SUPER ADMIN PAGES (Auth: super_admin)

| Page                      | APIs Consumed                                                                                                           | Notes                                     |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| **Super Admin Dashboard** | Everything in Admin Dashboard + system health metrics                                                                   | Staff overview, critical alerts           |
| **Staff Management**      | `GET /admin/users?role=2,3,5`, `POST /super-admin/staff`, `PUT /super-admin/staff/:id`, `DELETE /super-admin/staff/:id` | Tabs: Admins/Support/Experts              |
| **Super Admin Settings**  | `GET /admin/settings`, `PUT /admin/settings/:key` (commission, feature toggles, maintenance)                            | Impact preview for commission             |
| **Override & Emergency**  | `POST /super-admin/overrides`, `GET /admin/audit-logs`                                                                  | Reverse forfeitures, unsuspend, reinstate |

#### Super Admin Modals

| Modal                  | APIs Consumed             |
| ---------------------- | ------------------------- |
| **Create Staff Modal** | `POST /super-admin/staff` |

---

### 11.7 REVERSE MAP: API → Pages

| API Endpoint                             | Used By Pages                             |
| ---------------------------------------- | ----------------------------------------- |
| `POST /auth/register`                    | Register                                  |
| `POST /auth/verify-email`                | Verify Email                              |
| `POST /auth/login`                       | Login                                     |
| `POST /auth/refresh`                     | All authenticated pages (auto)            |
| `POST /auth/forgot-password`             | Forgot Password                           |
| `POST /auth/reset-password`              | Reset Password                            |
| `POST /auth/phone/send-otp`              | Settings (Verification)                   |
| `POST /auth/phone/verify-otp`            | Settings (Verification)                   |
| `POST /auth/id-verification`             | Verification Page                         |
| `GET /auth/id-verification`              | Verification Page                         |
| `GET /auth/me`                           | Profile, App Shell (header), Settings     |
| `PUT /auth/me`                           | Profile, Settings                         |
| `GET /items`                             | Home, Browse, My Listings                 |
| `GET /items/:id`                         | Item Details, Edit Item, Rental Details   |
| `POST /items`                            | Add Item                                  |
| `PUT /items/:id`                         | Edit Item, Admin Item Management          |
| `DELETE /items/:id`                      | My Listings, Admin Item Management        |
| `GET /search`                            | Browse, Search Results                    |
| `POST /items/:id/favorite`               | Item Details, Browse (heart btn)          |
| `DELETE /items/:id/favorite`             | Item Details, Favorites                   |
| `GET /users/me/favorites`                | Favorites                                 |
| `GET /items/:id/comments`                | Item Details                              |
| `POST /items/:id/comments`               | Item Details                              |
| `POST /items/:id/report`                 | Item Details (Report Modal)               |
| `POST /rentals`                          | Rent Modal                                |
| `GET /rentals`                           | My Rentals, Rental Requests               |
| `GET /rentals/:id`                       | Rental Details                            |
| `PUT /rentals/:id/confirm`               | Rental Details (owner view)               |
| `PUT /rentals/:id/evaluation-decision`   | Rental Details (renter view)              |
| `PUT /rentals/:id/activate`              | System (after payment)                    |
| `PUT /rentals/:id/complete`              | Rental Details (owner view)               |
| `PUT /rentals/:id/cancel`                | Rental Details (renter view)              |
| `POST /rentals/:id/extend`               | Rental Details (Extend Modal)             |
| `PUT /rentals/:id/extend/:extId/respond` | Rental Requests (owner)                   |
| `POST /orders`                           | Checkout                                  |
| `GET /orders`                            | My Orders                                 |
| `GET /orders/:id`                        | Order Details                             |
| `POST /payments`                         | Payment (Checkout Modal)                  |
| `GET /payments/:orderId`                 | Order Details                             |
| `GET /orders/:id/delivery`               | Order Details                             |
| `PUT /orders/:id/delivery`               | Admin Delivery                            |
| `POST /rentals/:id/review`               | Leave Review (Rental Details)             |
| `GET /items/:id/reviews`                 | Item Details                              |
| `POST /items/:id/verify`                 | Expert Verification Forms                 |
| `GET /items/:id/verifications`           | Expert Panel, Admin, Rental Details       |
| `GET /expert/assigned`                   | Expert Queue, Expert Dashboard            |
| `POST /support/tickets`                  | User Support, Dispute Modal               |
| `GET /support/tickets`                   | Support, Support Dashboard, Admin Support |
| `POST /support/tickets/:id/messages`     | Support, Support Dashboard, Admin Support |
| `PUT /support/tickets/:id/status`        | Support Dashboard, Admin Support          |
| `POST /support/tickets/:id/rate`         | Support (after resolution)                |
| `POST /chats`                            | Chat List, Item Details (contact owner)   |
| `GET /chats`                             | Chat List                                 |
| `GET /chats/:id/messages`                | Chat Room                                 |
| `POST /chats/:id/messages`               | Chat Room                                 |
| `GET /notifications`                     | Notifications, App Shell (bell icon)      |
| `PUT /notifications/:id/read`            | Notifications                             |
| `PUT /notifications/read-all`            | Notifications                             |
| `GET /recommendations`                   | Home                                      |
| `PUT /recommendations/:id/click`         | Home (on rec click)                       |
| `GET /admin/kpis`                        | Admin Dashboard                           |
| `GET /admin/kpis/latest`                 | Admin Dashboard                           |
| `GET /admin/gap`                         | Admin Analytics                           |
| `GET /admin/fraud`                       | Admin Analytics (Fraud)                   |
| `PUT /admin/fraud/:userId/whitelist`     | Admin Analytics (Fraud)                   |
| `GET /admin/users`                       | Admin Users, Super Admin Staff            |
| `PUT /admin/users/:id/status`            | Admin Users                               |
| `GET /admin/items/pending`               | Admin Item Management                     |
| `PUT /admin/items/:id/approve`           | Admin Item Management                     |
| `PUT /admin/items/:id/reject`            | Admin Item Management                     |
| `GET /admin/id-verifications/pending`    | Admin ID Queue                            |
| `PUT /admin/id-verifications/:id`        | Admin ID Queue                            |
| `GET /admin/disputes`                    | Admin Disputes                            |
| `PUT /admin/disputes/:id/resolve`        | Admin Disputes                            |
| `POST /admin/expert-assignments`         | Admin Expert Management                   |
| `GET /admin/expert-performance`          | Admin Expert Management                   |
| `GET /admin/settings`                    | Admin Settings, Super Admin Settings      |
| `PUT /admin/settings/:key`               | Admin Settings, Super Admin Settings      |
| `GET /admin/reports`                     | Admin (from flagged items)                |
| `GET /admin/audit-logs`                  | Super Admin Overrides, Admin Settings     |
| `POST /super-admin/staff`                | Super Admin Staff Management              |
| `PUT /super-admin/staff/:id`             | Super Admin Staff Management              |
| `DELETE /super-admin/staff/:id`          | Super Admin Staff Management              |
| `POST /super-admin/overrides`            | Super Admin Overrides                     |

---

### 11.8 TOTAL API COUNTS

| Metric                     | Count                                 |
| -------------------------- | ------------------------------------- |
| Total REST API Endpoints   | 70+                                   |
| Total WebSocket Events     | 12 (7 server→client, 5 client→server) |
| Total Frontend Pages       | 52+                                   |
| Public Pages (no auth)     | 11                                    |
| User Pages + Modals        | 18 pages + 11 modals                  |
| Expert Pages               | 6                                     |
| Support Pages              | 4                                     |
| Admin Pages + Modals       | 11 pages + 3 modals                   |
| Super Admin Pages + Modals | 4 pages + 1 modal                     |

---

## 12. REAL-TIME (WEBSOCKET) INTEGRATION

> **For Developers:** The system uses WebSocket for real-time features. REST APIs serve initial data fetching; WebSocket pushes live updates.

### 12.1 Technology

| Stack Option | Library       | When To Use                |
| ------------ | ------------- | -------------------------- |
| ASP.NET Core | **SignalR**   | If backend is C#/.NET      |
| Node.js      | **Socket.IO** | If backend is Node/Express |

### 12.2 Connection Lifecycle

```
1. User logs in → receives JWT
2. Client opens WebSocket: ws://api.renty.app/ws?token=<JWT>
3. Server validates JWT → subscribes user to personal channel
4. On token refresh → reconnect with new token
5. On logout → server disconnects + cleans up user channels
```

### 12.3 Which Pages Use Real-Time

| Page / Component       | WebSocket Events Used                                           | Fallback                                 |
| ---------------------- | --------------------------------------------------------------- | ---------------------------------------- |
| **Header (Bell Icon)** | `new_notification`, `unread_count_update`                       | Poll `GET /notifications` every 30s      |
| **Chat Room**          | `new_message`, `typing`, `stop_typing`, `message_read`          | Poll `GET /chats/:id/messages` every 10s |
| **Chat List**          | `new_message` (for last message preview), `unread_count_update` | Poll on page revisit                     |
| **Rental Details**     | `rental_status_change`                                          | User refreshes page                      |
| **Admin Dashboard**    | `new_notification` (disputes, fraud alerts)                     | Page reload                              |
| **Expert Queue**       | `new_notification` (new assignment)                             | Page reload                              |
| **Support Tickets**    | `new_notification` (ticket reply)                               | Page reload                              |

### 12.4 Developer Implementation Notes

- **Authentication:** WebSocket connection MUST validate JWT on handshake. Reject unauthenticated connections.
- **Reconnection:** Client auto-reconnects with exponential backoff (1s, 2s, 4s, 8s, max 30s).
- **Offline Queue:** Messages sent while disconnected are queued client-side and sent on reconnect.
- **Server Rooms:** Each user has a private room (`user:{userId}`). Chat rooms use (`chat:{chatId}`).
- **Rate Limiting:** Max 10 WebSocket messages per second per user. Excess → throttle.
- **MVP Simplification:** For MVP, WebSocket is optional. Polling is acceptable. WebSocket is the production target.
