# RENTY Deployment Guide

This document outlines the production deployment strategy for the RENTY platform, utilizing DigitalOcean App Platform for the backend, PostgreSQL, and Vercel for the 5 Angular frontends.

---

## 1. Environment Variables List

A complete list of secrets and configuration variables required across the environments:

**Backend (DigitalOcean App Platform)**
- `DATABASE_URL`: The PostgreSQL connection string (Automatically provided by DigitalOcean Managed DB, mapped to `ConnectionStrings__DefaultConnection`).
- `JWT_SECRET`: A long, secure random string used to sign JWT authentication tokens.
- `CLOUDINARY_URL`: Your Cloudinary connection string (e.g., `cloudinary://api_key:api_secret@cloud_name`).
- `CORS_ALLOWED_ORIGINS`: Comma-separated list of your Vercel frontend domains (e.g., `https://renty-web.vercel.app,https://renty-admin.vercel.app,...`).
- `SEED_ADMIN_EMAIL`: Email address of the primary SuperAdmin (defaults to `admin@rently.com`).

**Frontends (Vercel - Angular environments)**
- `apiUrl`: Set this in `environment.prod.ts` for all 5 apps to point to the DigitalOcean API URL (e.g., `https://renty-api.ondigitalocean.app/api/v1`).

---

## 2. Infrastructure Setup

### DigitalOcean (Backend & DB)
We use the **DigitalOcean App Platform** (PaaS) to run the `.NET Core` API and a Managed PostgreSQL database. This provides SSL, load balancing, and zero-downtime deployments.

1. Create a new App in DigitalOcean App Platform.
2. Connect the GitHub repository.
3. Import the `.do/app.yaml` file located in the root of the project. This automatically provisions the `renty-api` Web Service and the `renty-db` Managed Database.
4. Set the necessary Environment Variables listed above in the App settings.

### Vercel (Frontends)
The platform consists of 5 Angular SPAs (Web, Admin, SuperAdmin, Support, Expert).
1. Create 5 separate projects in Vercel.
2. For each project, import the `renty` repository.
3. Set the **Root Directory** for each project to its respective folder (e.g., `Client/Web`, `Client/Admin`).
4. Ensure the pre-configured `vercel.json` exists in each folder to handle Angular routing rewrites.

### Cloudinary (Media Storage)
All media (images, videos, verification documents) are stored in Cloudinary since the DigitalOcean App Platform containers have ephemeral storage. 
1. Obtain the `CLOUDINARY_URL` from the Cloudinary dashboard.
2. Add it to the DigitalOcean App Environment Variables.

---

## 3. Database Migration Strategy

We use **Manual Migrations** for production to minimize risk and avoid deployment locks during startup.

**Startup Migration Plan:**
1. Do **NOT** run `db.Database.Migrate()` automatically during app startup in production.
2. After a deployment that includes schema changes, run the migration command against the DigitalOcean Managed PostgreSQL database:
   ```bash
   dotnet ef database update --connection "<YOUR_DO_DATABASE_URL>"
   ```

---

## 4. PostgreSQL Backup Policy

To protect wallet balances, user data, and dispute logs, backups are strictly enforced:
- **Policy:** Daily automated backups.
- **Retention:** 7-14 days.
- **Configuration:** Handled automatically by DigitalOcean Managed Databases (verify this is enabled in the DO Database settings).

---

## 5. Deployment Order (Staged Rollout)

Follow this order when deploying the platform for the first time or during major updates:

### Step 1: Core Infrastructure
Deploy: **Backend, PostgreSQL, Cloudinary**.
- *Verify:* Visit the Swagger UI (`/swagger`).
- *Verify:* Hit the Health Check endpoint (`/api/health`) and ensure `Database` and `Cloudinary` report as `Connected`/`Configured`.

### Step 2: Customer Facing
Deploy: **Web (Renter/Owner Portal)**.
- *Verify:* Login, Register, Browse Items, and Create a new Item listing. Ensure Cloudinary image uploads succeed.

### Step 3: Staff Portals
Deploy: **Expert, Support, Admin, SuperAdmin**.
- *Verify:* Ensure staff can log in and access their respective dashboards.

### Step 4: Real-Time & Communications Verification
Test SignalR connections across the platform:
- *Verify:* Chat messages between Renter and Owner.
- *Verify:* Support Chat between Web user and Support Agent.
- *Verify:* Instant Notifications for rental requests and verification assignments.
- *Crucial:* Ensure no reconnect loops or WebSocket connection drops on DigitalOcean App Platform.

### Step 5: Financial Workflows
Test the core business logic:
- *Verify:* Escrow hold on Wallet during rental creation.
- *Verify:* Platform commission deductions.
- *Verify:* Deposit release and penalty deduction workflows.
- *Verify:* Dispute resolution flow.

---

## 6. Rollback Steps

If a deployment introduces critical bugs:
1. **Frontend:** Navigate to the Vercel Dashboard -> Project -> Deployments. Click the three dots next to the previous stable deployment and select **"Promote to Production"** to instantly revert.
2. **Backend:** In DigitalOcean App Platform, navigate to Activity -> Deployments. Find the last stable deployment and click **"Rollback"**.
3. **Database:** If a destructive migration was applied, use DigitalOcean Database Backups to restore to a point-in-time from before the deployment.
