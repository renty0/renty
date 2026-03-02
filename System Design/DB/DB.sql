-- ============================================================
-- RENTY — Rental Platform Database Schema (PostgreSQL)
-- Production-Inspired MVP — Clean, Constrained, Indexed
-- ============================================================

-- ========================
-- 1. EXTENSIONS
-- ========================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================
-- 2. ENUM TYPES
-- ========================

CREATE TYPE rental_status AS ENUM ('pending', 'confirmed', 'active', 'completed', 'cancelled', 'overdue');
CREATE TYPE order_status AS ENUM ('pending', 'paid', 'shipped', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'success', 'failed');
CREATE TYPE payment_method AS ENUM ('vodafone_cash', 'fawry', 'paymob', 'credit_card', 'bank_transfer');
CREATE TYPE deposit_status AS ENUM ('held', 'returned', 'forfeited');
CREATE TYPE item_status AS ENUM ('available', 'rented', 'under_review', 'suspended', 'removed');
CREATE TYPE item_type AS ENUM ('standard', 'premium');
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');
CREATE TYPE delivery_status AS ENUM ('processing', 'shipped', 'in_transit', 'delivered', 'returned', 'cancelled');
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'failed');
CREATE TYPE verification_check AS ENUM ('before_rent', 'after_return');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE fraud_decision AS ENUM ('safe', 'flagged', 'blocked');
CREATE TYPE interaction_action AS ENUM ('view', 'click', 'search', 'favorite', 'rent', 'review');

-- ========================
-- 3. DATASET / PRODUCT CATALOG
-- ========================

CREATE TABLE "product_category" (
  "product_category_key" int PRIMARY KEY,
  "category_name" varchar(100) NOT NULL UNIQUE
);

CREATE TABLE "product_subcategory" (
  "product_subcategory_key" int PRIMARY KEY,
  "subcategory_name" varchar(100) NOT NULL,
  "product_category_key" int NOT NULL,
  UNIQUE ("subcategory_name", "product_category_key")
);

CREATE TABLE "product_lookup" (
  "product_key" int PRIMARY KEY,
  "product_subcategory_key" int NOT NULL,
  "product_name" varchar(200) NOT NULL,
  "product_price" decimal(10,2) NOT NULL CHECK ("product_price" >= 0)
);

-- ========================
-- 4. ROLES & PERMISSIONS
-- ========================

CREATE TABLE "roles" (
  "id" int PRIMARY KEY,  -- seeded manually (not serial)
  "name" varchar(50) NOT NULL UNIQUE
  -- values: 1=user, 2=admin, 3=support, 4=super_admin, 5=expert
);

CREATE TABLE "permissions" (
  "id" int PRIMARY KEY,
  "name" varchar(100) NOT NULL UNIQUE
  -- values: create_item, manage_users, view_kpi, etc.
);

CREATE TABLE "role_permissions" (
  "role_id" int NOT NULL,
  "permission_id" int NOT NULL,
  PRIMARY KEY ("role_id", "permission_id")
);

-- ========================
-- 5. USERS
-- ========================

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "first_name" varchar(100) NOT NULL,
  "last_name" varchar(100) NOT NULL,
  "email" varchar(255) NOT NULL UNIQUE,
  "password_hash" varchar(255) NOT NULL,
  "phone" varchar(20),
  "national_id" varchar(14),
  "address" text,
  "city" varchar(100),
  "profile_image_url" varchar(500),
  "role_id" int NOT NULL,
  "is_verified" boolean NOT NULL DEFAULT FALSE,
  "is_active" boolean NOT NULL DEFAULT TRUE,
  "last_login_at" timestamp,
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "created_by" uuid,
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "email_verifications" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "token" varchar(255) NOT NULL,
  "expires_at" timestamp NOT NULL,
  "is_used" boolean NOT NULL DEFAULT FALSE,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 6. ITEMS & PRICING
-- ========================

CREATE TABLE "items" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "product_key" int NOT NULL,
  "owner_id" uuid NOT NULL,
  "title" varchar(200) NOT NULL,
  "description" text,
  "type" item_type NOT NULL DEFAULT 'standard',
  "status" item_status NOT NULL DEFAULT 'available',
  "condition" varchar(50),  -- new, like_new, good, fair
  "default_deposit" decimal(10,2) NOT NULL DEFAULT 0 CHECK ("default_deposit" >= 0),
  "location" varchar(200),
  "city" varchar(100),
  "lat" decimal(10,7),
  "lng" decimal(10,7),
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "item_pricing" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "item_id" uuid NOT NULL,
  "price" decimal(10,2) NOT NULL CHECK ("price" > 0),
  "pricing_type" varchar(20) NOT NULL  -- daily, weekly, monthly
);

CREATE TABLE "item_images" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "item_id" uuid NOT NULL,
  "image_url" varchar(500) NOT NULL,
  "is_primary" boolean NOT NULL DEFAULT FALSE,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 7. ORDERS & PAYMENTS
-- ========================

CREATE TABLE "orders" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "total_amount" decimal(10,2) CHECK ("total_amount" >= 0),
  "status" order_status NOT NULL DEFAULT 'pending',
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "order_items" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "order_id" uuid NOT NULL,
  "item_id" uuid NOT NULL,
  "quantity" int NOT NULL DEFAULT 1 CHECK ("quantity" > 0),
  "price_at_time" decimal(10,2) NOT NULL CHECK ("price_at_time" >= 0)
);

CREATE TABLE "payments" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "order_id" uuid NOT NULL,
  "amount" decimal(10,2) NOT NULL CHECK ("amount" > 0),
  "method" payment_method NOT NULL,
  "status" payment_status NOT NULL DEFAULT 'pending',
  "transaction_ref" varchar(100),
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 8. RENTALS
-- ========================

CREATE TABLE "rentals" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "item_id" uuid NOT NULL,
  "order_id" uuid,
  "rental_price" decimal(10,2) NOT NULL CHECK ("rental_price" >= 0),
  "start_date" timestamp NOT NULL,
  "end_date" timestamp NOT NULL,
  "actual_return_date" timestamp,
  "late_fee" decimal(10,2) NOT NULL DEFAULT 0 CHECK ("late_fee" >= 0),
  "status" rental_status NOT NULL DEFAULT 'pending',
  "deposit_amount" decimal(10,2) NOT NULL DEFAULT 0 CHECK ("deposit_amount" >= 0),
  "deposit_status" deposit_status NOT NULL DEFAULT 'held',
  "notes" text,
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 9. DELIVERY
-- ========================

CREATE TABLE "delivery_tracking" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "order_id" uuid NOT NULL,
  "status" delivery_status NOT NULL DEFAULT 'processing',
  "location" varchar(200),
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 10. INTERACTIONS & AI
-- ========================

CREATE TABLE "user_interactions" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "item_id" uuid,
  "action" interaction_action NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "search_logs" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid,
  "query" varchar(500) NOT NULL,
  "category_id" int,
  "results_count" int NOT NULL DEFAULT 0 CHECK ("results_count" >= 0),
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "recommendations" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "item_id" uuid NOT NULL,
  "score" decimal(5,4) NOT NULL CHECK ("score" >= 0 AND "score" <= 1),
  "algorithm" varchar(50),  -- content_based, collaborative, hybrid
  "reason" text,
  "is_clicked" boolean NOT NULL DEFAULT FALSE,
  "is_rented" boolean NOT NULL DEFAULT FALSE,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "fraud_logs" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "risk_score" decimal(5,4) NOT NULL CHECK ("risk_score" >= 0 AND "risk_score" <= 1),
  "decision" fraud_decision NOT NULL DEFAULT 'safe',
  "reason" text,
  "fraud_indicators" jsonb,
  "model_version" varchar(20),
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "gap_results" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "category_id" int NOT NULL,
  "demand" int NOT NULL CHECK ("demand" >= 0),
  "supply" int NOT NULL CHECK ("supply" >= 0),
  "gap_score" decimal(10,2) NOT NULL,
  "period" varchar(20) NOT NULL DEFAULT 'daily',
  "recommendations" text,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "kpis_snapshots_derived" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "date" date NOT NULL,
  "period" varchar(20) NOT NULL DEFAULT 'daily',
  "active_users" int NOT NULL DEFAULT 0,
  "new_users" int NOT NULL DEFAULT 0,
  "total_items" int NOT NULL DEFAULT 0,
  "active_rentals" int NOT NULL DEFAULT 0,
  "rentals" int NOT NULL DEFAULT 0,
  "revenue" decimal(12,2) NOT NULL DEFAULT 0,
  "avg_rental_duration" decimal(8,2),
  "fraud_rate" decimal(5,4),
  "recommendation_ctr" decimal(5,4),
  "gap_score_avg" decimal(10,2),
  "avg_order_value" decimal(10,2),
  "cancellation_rate" decimal(5,4),
  "search_count" int NOT NULL DEFAULT 0
);

-- ========================
-- 11. SUPPORT & CHAT
-- ========================

CREATE TABLE "support_tickets" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "type" varchar(50) NOT NULL,
  "status" ticket_status NOT NULL DEFAULT 'open',
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "support_messages" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "ticket_id" uuid NOT NULL,
  "sender_id" uuid NOT NULL,
  "message" text NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "chats" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user1_id" uuid NOT NULL,
  "user2_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "chat_messages" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "chat_id" uuid NOT NULL,
  "sender_id" uuid NOT NULL,
  "message" text NOT NULL,
  "is_read" boolean NOT NULL DEFAULT FALSE,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 12. NOTIFICATIONS
-- ========================

CREATE TABLE "notifications" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "send_email" boolean NOT NULL DEFAULT FALSE,
  "title" varchar(200) NOT NULL,
  "message" text NOT NULL,
  "is_read" boolean NOT NULL DEFAULT FALSE,
  "status" notification_status NOT NULL DEFAULT 'pending',
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

-- ========================
-- 13. FAVORITES, REVIEWS, VERIFICATIONS
-- ========================

CREATE TABLE "favorites" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "user_id" uuid NOT NULL,
  "item_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "reviews" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "rental_id" uuid NOT NULL,
  "reviewer_id" uuid NOT NULL,
  "rating" int NOT NULL CHECK ("rating" >= 1 AND "rating" <= 5),
  "comment" text,
  "created_at" timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE "item_verifications" (
  "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  "item_id" uuid NOT NULL,
  "expert_id" uuid,
  "rental_id" uuid,
  "check_type" verification_check NOT NULL,
  "status" verification_status NOT NULL DEFAULT 'pending',
  "notes" text,
  "created_at" timestamp NOT NULL DEFAULT NOW(),
  "updated_at" timestamp NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 14. INDEXES
-- ============================================================

-- Item Pricing
CREATE UNIQUE INDEX idx_item_pricing_unique ON "item_pricing" ("item_id", "pricing_type");

-- Items
CREATE INDEX idx_items_owner ON "items" ("owner_id");
CREATE INDEX idx_items_status ON "items" ("status");
CREATE INDEX idx_items_product ON "items" ("product_key");
CREATE INDEX idx_items_city ON "items" ("city");

-- Rentals
CREATE INDEX idx_rentals_user ON "rentals" ("user_id");
CREATE INDEX idx_rentals_item ON "rentals" ("item_id");
CREATE INDEX idx_rentals_order ON "rentals" ("order_id");
CREATE INDEX idx_rentals_status ON "rentals" ("status");
CREATE INDEX idx_rentals_dates ON "rentals" ("start_date", "end_date");

-- Orders
CREATE INDEX idx_orders_user ON "orders" ("user_id");

-- Order Items
CREATE INDEX idx_order_items_order ON "order_items" ("order_id");
CREATE INDEX idx_order_items_item ON "order_items" ("item_id");

-- Payments
CREATE INDEX idx_payments_order ON "payments" ("order_id");

-- User Interactions
CREATE INDEX idx_interactions_user_action ON "user_interactions" ("user_id", "action");
CREATE INDEX idx_interactions_item ON "user_interactions" ("item_id");
CREATE INDEX idx_interactions_created ON "user_interactions" ("created_at");

-- Search Logs (powers Gap Analysis)
CREATE INDEX idx_search_logs_category ON "search_logs" ("category_id");
CREATE INDEX idx_search_logs_created ON "search_logs" ("created_at");
CREATE INDEX idx_search_logs_user ON "search_logs" ("user_id");

-- Recommendations
CREATE INDEX idx_recommendations_user ON "recommendations" ("user_id");

-- Fraud Logs
CREATE INDEX idx_fraud_logs_user ON "fraud_logs" ("user_id");
CREATE INDEX idx_fraud_logs_risk ON "fraud_logs" ("risk_score");

-- Gap Results
CREATE INDEX idx_gap_results_category ON "gap_results" ("category_id");
CREATE INDEX idx_gap_results_score ON "gap_results" ("gap_score" DESC);

-- KPI Snapshots
CREATE INDEX idx_kpis_date ON "kpis_snapshots_derived" ("date");

-- Support
CREATE INDEX idx_support_tickets_user ON "support_tickets" ("user_id");
CREATE INDEX idx_support_messages_ticket ON "support_messages" ("ticket_id");

-- Chat
CREATE UNIQUE INDEX idx_chats_pair ON "chats" ("user1_id", "user2_id");
CREATE INDEX idx_chat_messages_chat ON "chat_messages" ("chat_id");

-- Delivery
CREATE INDEX idx_delivery_order ON "delivery_tracking" ("order_id", "updated_at");

-- Notifications
CREATE INDEX idx_notifications_user_unread ON "notifications" ("user_id", "is_read") WHERE "is_read" = FALSE;

-- Favorites
CREATE UNIQUE INDEX idx_favorites_unique ON "favorites" ("user_id", "item_id");

-- Reviews
CREATE UNIQUE INDEX idx_reviews_rental ON "reviews" ("rental_id");  -- one review per rental

-- Item Images
CREATE INDEX idx_item_images_item ON "item_images" ("item_id");

-- ============================================================
-- 15. FOREIGN KEYS
-- ============================================================

-- Product Catalog
ALTER TABLE "product_subcategory" ADD FOREIGN KEY ("product_category_key") REFERENCES "product_category" ("product_category_key");
ALTER TABLE "product_lookup" ADD FOREIGN KEY ("product_subcategory_key") REFERENCES "product_subcategory" ("product_subcategory_key");

-- Users
ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");
ALTER TABLE "users" ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");
ALTER TABLE "email_verifications" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

-- Items
ALTER TABLE "items" ADD FOREIGN KEY ("product_key") REFERENCES "product_lookup" ("product_key");
ALTER TABLE "items" ADD FOREIGN KEY ("owner_id") REFERENCES "users" ("id");
ALTER TABLE "item_pricing" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "item_images" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");

-- Orders & Payments
ALTER TABLE "orders" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("id");
ALTER TABLE "order_items" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("id");

-- Rentals
ALTER TABLE "rentals" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "rentals" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "rentals" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("id");

-- Delivery
ALTER TABLE "delivery_tracking" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("id");

-- Interactions & AI
ALTER TABLE "user_interactions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "user_interactions" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "search_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "search_logs" ADD FOREIGN KEY ("category_id") REFERENCES "product_category" ("product_category_key");
ALTER TABLE "recommendations" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "recommendations" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "fraud_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "gap_results" ADD FOREIGN KEY ("category_id") REFERENCES "product_category" ("product_category_key");

-- Support & Chat
ALTER TABLE "support_tickets" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "support_messages" ADD FOREIGN KEY ("ticket_id") REFERENCES "support_tickets" ("id");
ALTER TABLE "support_messages" ADD FOREIGN KEY ("sender_id") REFERENCES "users" ("id");
ALTER TABLE "chats" ADD FOREIGN KEY ("user1_id") REFERENCES "users" ("id");
ALTER TABLE "chats" ADD FOREIGN KEY ("user2_id") REFERENCES "users" ("id");
ALTER TABLE "chat_messages" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id");
ALTER TABLE "chat_messages" ADD FOREIGN KEY ("sender_id") REFERENCES "users" ("id");

-- Notifications, Favorites, Reviews, Verifications
ALTER TABLE "notifications" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "favorites" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "favorites" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "reviews" ADD FOREIGN KEY ("rental_id") REFERENCES "rentals" ("id");
ALTER TABLE "reviews" ADD FOREIGN KEY ("reviewer_id") REFERENCES "users" ("id");
ALTER TABLE "item_verifications" ADD FOREIGN KEY ("item_id") REFERENCES "items" ("id");
ALTER TABLE "item_verifications" ADD FOREIGN KEY ("expert_id") REFERENCES "users" ("id");
ALTER TABLE "item_verifications" ADD FOREIGN KEY ("rental_id") REFERENCES "rentals" ("id");

-- RBAC
ALTER TABLE "role_permissions" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");
ALTER TABLE "role_permissions" ADD FOREIGN KEY ("permission_id") REFERENCES "permissions" ("id");

-- ============================================================
-- 16. TRIGGER FUNCTION: Auto-update updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON "users"
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_items_updated_at
  BEFORE UPDATE ON "items"
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_rentals_updated_at
  BEFORE UPDATE ON "rentals"
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON "orders"
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_support_tickets_updated_at
  BEFORE UPDATE ON "support_tickets"
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_item_verifications_updated_at
  BEFORE UPDATE ON "item_verifications"
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- ============================================================
-- 17. TRIGGER: Prevent user from renting their own item
-- ============================================================

CREATE OR REPLACE FUNCTION fn_prevent_self_rental()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id = (SELECT owner_id FROM items WHERE id = NEW.item_id) THEN
    RAISE EXCEPTION 'A user cannot rent their own item';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_self_rental
  BEFORE INSERT ON "rentals"
  FOR EACH ROW EXECUTE FUNCTION fn_prevent_self_rental();

-- ============================================================
-- 17b. TRIGGER: Prevent expert from verifying their own item
-- ============================================================

CREATE OR REPLACE FUNCTION fn_prevent_self_verification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.expert_id = (SELECT owner_id FROM items WHERE id = NEW.item_id) THEN
    RAISE EXCEPTION 'An expert cannot verify their own item';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_self_verification
  BEFORE INSERT ON "item_verifications"
  FOR EACH ROW EXECUTE FUNCTION fn_prevent_self_verification();

-- ============================================================
-- 18. COMMENTS (documentation for team)
-- ============================================================

COMMENT ON TABLE "search_logs" IS 'Tracks user searches — used for Gap Analysis (demand calculation)';
COMMENT ON TABLE "gap_results" IS 'Supply-demand gap scores per category — computed by analytics pipeline';
COMMENT ON TABLE "kpis_snapshots_derived" IS 'Daily/weekly KPI snapshots — computed by analytics pipeline';
COMMENT ON TABLE "fraud_logs" IS 'AI fraud detection results — risk scores per user';
COMMENT ON TABLE "recommendations" IS 'AI recommendation engine output — scored item suggestions';
COMMENT ON TABLE "user_interactions" IS 'Tracks clicks/views/favorites — feeds recommendation engine';
COMMENT ON TABLE "item_verifications" IS 'Expert checks done before_rent or after_return';

COMMENT ON COLUMN "rentals"."status" IS 'pending → confirmed → active → completed/cancelled/overdue';
COMMENT ON COLUMN "orders"."status" IS 'pending → paid → shipped → delivered / cancelled';
COMMENT ON COLUMN "payments"."status" IS 'pending → success / failed';
COMMENT ON COLUMN "support_tickets"."status" IS 'open → in_progress → resolved → closed';
COMMENT ON COLUMN "reviews"."rating" IS 'Integer 1 to 5, enforced by CHECK constraint';
COMMENT ON COLUMN "fraud_logs"."risk_score" IS 'Float 0.0 to 1.0 — higher means riskier';
COMMENT ON COLUMN "recommendations"."score" IS 'Float 0.0 to 1.0 — higher means stronger recommendation';
COMMENT ON COLUMN "items"."condition" IS 'Text: new, like_new, good, fair';

-- ============================================================
-- 19. VIEWS (Admin Dashboard & Analytics)
-- ============================================================

-- Active rentals with user + item details
CREATE OR REPLACE VIEW v_active_rentals AS
SELECT
  r.id AS rental_id,
  r.user_id AS renter_id,
  u.first_name || ' ' || u.last_name AS renter_name,
  r.item_id,
  i.title AS item_title,
  r.rental_price,
  r.deposit_amount,
  r.start_date,
  r.end_date,
  r.status,
  r.created_at
FROM rentals r
JOIN users u ON r.user_id = u.id
JOIN items i ON r.item_id = i.id
WHERE r.status = 'active';

-- Overdue rentals for admin alerts
CREATE OR REPLACE VIEW v_overdue_rentals AS
SELECT
  r.id AS rental_id,
  u.first_name || ' ' || u.last_name AS renter_name,
  u.email AS renter_email,
  u.phone AS renter_phone,
  i.title AS item_title,
  ow.first_name || ' ' || ow.last_name AS owner_name,
  r.end_date,
  NOW() - r.end_date AS overdue_duration,
  r.deposit_amount,
  r.deposit_status
FROM rentals r
JOIN users u ON r.user_id = u.id
JOIN items i ON r.item_id = i.id
JOIN users ow ON i.owner_id = ow.id
WHERE r.status IN ('active', 'overdue')
  AND r.end_date < NOW();

-- Top gap categories (demand vs supply)
CREATE OR REPLACE VIEW v_top_gap_categories AS
SELECT
  g.id,
  pc.category_name,
  g.demand,
  g.supply,
  g.gap_score,
  g.period,
  g.recommendations,
  g.created_at
FROM gap_results g
JOIN product_category pc ON g.category_id = pc.product_category_key
ORDER BY g.gap_score DESC;

-- Item availability with price + rating
CREATE OR REPLACE VIEW v_item_availability AS
SELECT
  i.id AS item_id,
  i.title,
  i.status,
  i.city,
  i.condition,
  i.type,
  pl.product_name,
  pc.category_name,
  ip.price AS daily_price,
  COALESCE(AVG(rv.rating), 0) AS avg_rating,
  COUNT(rv.id) AS review_count
FROM items i
JOIN product_lookup pl ON i.product_key = pl.product_key
JOIN product_subcategory ps ON pl.product_subcategory_key = ps.product_subcategory_key
JOIN product_category pc ON ps.product_category_key = pc.product_category_key
LEFT JOIN item_pricing ip ON ip.item_id = i.id AND ip.pricing_type = 'daily'
LEFT JOIN rentals rt ON rt.item_id = i.id
LEFT JOIN reviews rv ON rv.rental_id = rt.id
GROUP BY i.id, i.title, i.status, i.city, i.condition, i.type,
         pl.product_name, pc.category_name, ip.price;

-- User risk overview (latest fraud decision per user)
CREATE OR REPLACE VIEW v_user_risk_overview AS
SELECT DISTINCT ON (fl.user_id)
  fl.user_id,
  u.first_name || ' ' || u.last_name AS user_name,
  u.email,
  u.is_active,
  fl.risk_score,
  fl.decision,
  fl.reason,
  fl.created_at AS last_checked
FROM fraud_logs fl
JOIN users u ON fl.user_id = u.id
ORDER BY fl.user_id, fl.created_at DESC;

-- Latest daily KPI snapshot
CREATE OR REPLACE VIEW v_daily_kpi_latest AS
SELECT *
FROM kpis_snapshots_derived
ORDER BY date DESC
LIMIT 1;

-- Recommendation performance (CTR + conversion per algorithm)
CREATE OR REPLACE VIEW v_recommendation_performance AS
SELECT
  algorithm,
  COUNT(*) AS total_recommendations,
  COUNT(*) FILTER (WHERE is_clicked = TRUE) AS clicks,
  COUNT(*) FILTER (WHERE is_rented = TRUE) AS conversions,
  ROUND(
    COUNT(*) FILTER (WHERE is_clicked = TRUE)::decimal / NULLIF(COUNT(*), 0), 4
  ) AS ctr,
  ROUND(
    COUNT(*) FILTER (WHERE is_rented = TRUE)::decimal / NULLIF(COUNT(*), 0), 4
  ) AS conversion_rate
FROM recommendations
GROUP BY algorithm;

-- ============================================================
-- 20. SEED DATA (Roles, Permissions, Role-Permission Mapping)
-- ============================================================

-- Roles
INSERT INTO "roles" ("id", "name") VALUES
  (1, 'user'),
  (2, 'admin'),
  (3, 'support'),
  (4, 'super_admin'),
  (5, 'expert');

-- Permissions (granular, one per API action group)
INSERT INTO "permissions" ("id", "name") VALUES
  -- Items
  (1,  'items.browse'),           -- GET /items, GET /items/:id
  (2,  'items.create'),           -- POST /items
  (3,  'items.edit_own'),         -- PUT /items/:id (own)
  (4,  'items.edit_any'),         -- PUT /items/:id (any)
  (5,  'items.delete_own'),       -- DELETE /items/:id (own)
  (6,  'items.delete_any'),       -- DELETE /items/:id (any)
  -- Rentals
  (7,  'rentals.create'),         -- POST /rentals
  (8,  'rentals.view_own'),       -- GET /rentals (own)
  (9,  'rentals.view_all'),       -- GET /rentals (all)
  (10, 'rentals.manage'),         -- confirm, activate, complete, cancel
  -- Orders & Payments
  (11, 'orders.create'),          -- POST /orders
  (12, 'orders.view_own'),        -- GET /orders (own)
  (13, 'orders.view_all'),        -- GET /orders (all)
  (14, 'payments.create'),        -- POST /payments
  -- Favorites & Search
  (15, 'favorites.manage'),       -- POST/DELETE /items/:id/favorite
  (16, 'search.use'),             -- GET /search
  -- Reviews & Verifications
  (17, 'reviews.create'),         -- POST /rentals/:id/review
  (18, 'verifications.perform'),  -- POST /items/:id/verify (expert/admin)
  (19, 'verifications.view'),     -- GET /items/:id/verifications
  -- Support & Chat
  (20, 'support.create_ticket'),  -- POST /support/tickets
  (21, 'support.manage_tickets'), -- change status, view all tickets
  (22, 'chat.use'),               -- POST/GET /chats
  -- Admin
  (23, 'admin.view_kpis'),        -- GET /admin/kpis
  (24, 'admin.view_gap'),         -- GET /admin/gap
  (25, 'admin.view_fraud'),       -- GET /admin/fraud
  (26, 'admin.manage_users'),     -- GET /admin/users, PUT /admin/users/:id/status
  -- Delivery
  (27, 'delivery.view_own'),      -- GET /orders/:id/delivery (own)
  (28, 'delivery.manage'),        -- PUT /orders/:id/delivery
  -- Recommendations
  (29, 'recommendations.view');   -- GET /recommendations

-- Role ↔ Permission Mapping
-- 1 = user
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
  (1, 1),   -- items.browse
  (1, 2),   -- items.create
  (1, 3),   -- items.edit_own
  (1, 5),   -- items.delete_own
  (1, 7),   -- rentals.create
  (1, 8),   -- rentals.view_own
  (1, 10),  -- rentals.manage (own: confirm as owner, cancel as renter)
  (1, 11),  -- orders.create
  (1, 12),  -- orders.view_own
  (1, 14),  -- payments.create
  (1, 15),  -- favorites.manage
  (1, 16),  -- search.use
  (1, 17),  -- reviews.create
  (1, 19),  -- verifications.view (own items)
  (1, 20),  -- support.create_ticket
  (1, 22),  -- chat.use
  (1, 27),  -- delivery.view_own
  (1, 29);  -- recommendations.view

-- 2 = admin
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
  (2, 1),   -- items.browse
  (2, 4),   -- items.edit_any
  (2, 6),   -- items.delete_any
  (2, 9),   -- rentals.view_all
  (2, 10),  -- rentals.manage (activate, complete)
  (2, 13),  -- orders.view_all
  (2, 15),  -- favorites.manage
  (2, 16),  -- search.use
  (2, 18),  -- verifications.perform
  (2, 19),  -- verifications.view
  (2, 20),  -- support.create_ticket
  (2, 21),  -- support.manage_tickets
  (2, 22),  -- chat.use
  (2, 23),  -- admin.view_kpis
  (2, 24),  -- admin.view_gap
  (2, 25),  -- admin.view_fraud
  (2, 26),  -- admin.manage_users
  (2, 27),  -- delivery.view_own
  (2, 28);  -- delivery.manage

-- 3 = support
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
  (3, 1),   -- items.browse
  (3, 16),  -- search.use
  (3, 20),  -- support.create_ticket
  (3, 21),  -- support.manage_tickets
  (3, 27);  -- delivery.view_own

-- 4 = super_admin (everything)
INSERT INTO "role_permissions" ("role_id", "permission_id")
SELECT 4, "id" FROM "permissions";

-- 5 = expert
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
  (5, 1),   -- items.browse
  (5, 16),  -- search.use
  (5, 18),  -- verifications.perform
  (5, 19),  -- verifications.view
  (5, 20);  -- support.create_ticket

-- ============================================================
-- END OF SCHEMA
-- ============================================================
