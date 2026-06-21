TRUNCATE TABLE "RentRequests" CASCADE;
TRUNCATE TABLE "rentals" CASCADE;
TRUNCATE TABLE "wallet_transactions" CASCADE;
TRUNCATE TABLE "payments" CASCADE;
UPDATE "Users" SET "WalletBalance" = 0, "PendingBalance" = 0;
