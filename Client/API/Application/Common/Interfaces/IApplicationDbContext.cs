using Domain.Entities;

using Microsoft.EntityFrameworkCore;

namespace Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<RefreshToken> RefreshTokens { get; }
    DbSet<ProductCategory> ProductCategories { get; }
    DbSet<Brand> Brands { get; }
    DbSet<ProductSubcategory> ProductSubcategories { get; }
    DbSet<Product> Products { get; }
    DbSet<Calendar> Calendars { get; }
    DbSet<Territory> Territories { get; }
    DbSet<Customer> Customers { get; }
    DbSet<Sale> Sales { get; }
    DbSet<Return> Returns { get; }
    DbSet<RentableItem> RentableItems { get; }
    DbSet<RentableItemImage> RentableItemImages { get; }
    DbSet<RentRequest> RentRequests { get; }
    DbSet<MediaFile> MediaFiles { get; }
    DbSet<ProductImage> ProductImages { get; }
    DbSet<GapAnalysisResult> GapAnalysisResults { get; }
    DbSet<ApplicationUser> Users { get; }

    // New schema entities
    DbSet<Item> Items { get; }
    DbSet<ItemPricing> ItemPricings { get; }
    DbSet<ItemImage> ItemImages { get; }
    DbSet<Favorite> Favorites { get; }
    DbSet<SearchLog> SearchLogs { get; }
    DbSet<UserInteraction> UserInteractions { get; }
    DbSet<Permission> Permissions { get; }
    DbSet<RolePermission> RolePermissions { get; }

    // Rentals, Orders, Payments, Delivery, Reviews, Verifications
    DbSet<Rental> Rentals { get; }
    DbSet<Order> Orders { get; }
    DbSet<OrderItem> OrderItems { get; }
    DbSet<Payment> Payments { get; }
    DbSet<DeliveryTracking> DeliveryTrackings { get; }
    DbSet<Review> Reviews { get; }
    DbSet<ItemVerification> ItemVerifications { get; }
    DbSet<IdVerification> IdVerifications { get; }
    DbSet<WalletTransaction> WalletTransactions { get; }
    DbSet<SystemSetting> SystemSettings { get; }

    // Support, Chat, Notifications, Recommendations, KPIs
    DbSet<SupportTicket> SupportTickets { get; }
    DbSet<SupportMessage> SupportMessages { get; }
    DbSet<SupportTicketEvent> SupportTicketEvents { get; }
    DbSet<Chat> Chats { get; }
    DbSet<ChatMessage> ChatMessages { get; }
    DbSet<Notification> Notifications { get; }
    DbSet<ItemReminder> ItemReminders { get; }
    DbSet<ItemRecommendation> ItemRecommendations { get; }
    DbSet<KpiSnapshot> KpiSnapshots { get; }

    // Admin — Fraud
    DbSet<FraudLog> FraudLogs { get; }
    DbSet<RentalImage> RentalImages { get; }
    DbSet<RentalExtension> RentalExtensions { get; }
    DbSet<RentalTransfer> RentalTransfers { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
