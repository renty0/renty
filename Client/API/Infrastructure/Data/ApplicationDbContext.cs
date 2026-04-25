using System.Reflection;
using Application.Common.Interfaces;
using Domain.Entities;

using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, long>, IApplicationDbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<ProductCategory> ProductCategories => Set<ProductCategory>();
    public DbSet<Brand> Brands => Set<Brand>();
    public DbSet<ProductSubcategory> ProductSubcategories => Set<ProductSubcategory>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Calendar> Calendars => Set<Calendar>();
    public DbSet<Territory> Territories => Set<Territory>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Sale> Sales => Set<Sale>();
    public DbSet<Return> Returns => Set<Return>();
    public DbSet<RentableItem> RentableItems => Set<RentableItem>();
    public DbSet<RentableItemImage> RentableItemImages => Set<RentableItemImage>();
    public DbSet<RentRequest> RentRequests => Set<RentRequest>();
    public DbSet<MediaFile> MediaFiles => Set<MediaFile>();
    public DbSet<ProductImage> ProductImages => Set<ProductImage>();
    public DbSet<GapAnalysisResult> GapAnalysisResults => Set<GapAnalysisResult>();

    // New schema entities
    public DbSet<Item> Items => Set<Item>();
    public DbSet<ItemPricing> ItemPricings => Set<ItemPricing>();
    public DbSet<ItemImage> ItemImages => Set<ItemImage>();
    public DbSet<Favorite> Favorites => Set<Favorite>();
    public DbSet<SearchLog> SearchLogs => Set<SearchLog>();
    public DbSet<UserInteraction> UserInteractions => Set<UserInteraction>();
    public DbSet<Permission> Permissions => Set<Permission>();
    public DbSet<RolePermission> RolePermissions => Set<RolePermission>();

    // Rentals, Orders, Payments, Delivery, Reviews, Verifications
    public DbSet<Rental> Rentals => Set<Rental>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<DeliveryTracking> DeliveryTrackings => Set<DeliveryTracking>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<ItemVerification> ItemVerifications => Set<ItemVerification>();
    public DbSet<IdVerification> IdVerifications => Set<IdVerification>();
    public DbSet<WalletTransaction> WalletTransactions => Set<WalletTransaction>();
    public DbSet<SystemSetting> SystemSettings => Set<SystemSetting>();

    // Support, Chat, Notifications, Recommendations, KPIs
    public DbSet<SupportTicket> SupportTickets => Set<SupportTicket>();
    public DbSet<SupportMessage> SupportMessages => Set<SupportMessage>();
    public DbSet<Chat> Chats => Set<Chat>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<ItemRecommendation> ItemRecommendations => Set<ItemRecommendation>();
    public DbSet<KpiSnapshot> KpiSnapshots => Set<KpiSnapshot>();
    public DbSet<FraudLog> FraudLogs => Set<FraudLog>();
    public DbSet<RentalImage> RentalImages => Set<RentalImage>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        // Customize Identity table names
        builder.Entity<ApplicationUser>(entity =>
        {
            entity.ToTable("Users");
        });

        builder.Entity<ApplicationRole>(entity =>
        {
            entity.ToTable("Roles");
        });

        // New schema table mappings
        builder.Entity<Brand>(entity =>
        {
            entity.ToTable("brands");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NameEn).IsRequired().HasMaxLength(100);
            entity.Property(e => e.NameAr).IsRequired().HasMaxLength(100);
        });

        builder.Entity<Item>(entity =>
        {
            entity.ToTable("items");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.OwnerId).HasColumnName("owner_id");
            entity.Property(e => e.TitleEn).HasColumnName("title_en").HasMaxLength(200);
            entity.Property(e => e.TitleAr).HasColumnName("title_ar").HasMaxLength(200);
            entity.Property(e => e.DescEn).HasColumnName("desc_en");
            entity.Property(e => e.DescAr).HasColumnName("desc_ar");
            entity.Property(e => e.Type).HasColumnName("type").HasConversion<string>();
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.Condition).HasColumnName("condition").HasMaxLength(50);
            entity.Property(e => e.DefaultDeposit).HasColumnName("default_deposit").HasPrecision(10, 2);
            entity.Property(e => e.Location).HasColumnName("location").HasMaxLength(200);
            entity.Property(e => e.City).HasColumnName("city").HasMaxLength(100);
            entity.Property(e => e.Lat).HasColumnName("lat").HasPrecision(10, 7);
            entity.Property(e => e.Lng).HasColumnName("lng").HasPrecision(10, 7);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.Property(e => e.CategoryId).HasColumnName("category_id");
            entity.Property(e => e.SubcategoryId).HasColumnName("subcategory_id");
            entity.Property(e => e.BrandId).HasColumnName("brand_id");
            entity.HasOne(e => e.Owner).WithMany(u => u.Items).HasForeignKey(e => e.OwnerId);
            entity.HasOne(e => e.Category).WithMany().HasForeignKey(e => e.CategoryId).IsRequired(false);
            entity.HasOne(e => e.Subcategory).WithMany().HasForeignKey(e => e.SubcategoryId).IsRequired(false);
            entity.HasOne(e => e.Brand).WithMany(b => b.Items).HasForeignKey(e => e.BrandId).IsRequired(false);
        });

        builder.Entity<ItemPricing>(entity =>
        {
            entity.ToTable("item_pricing");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.Price).HasColumnName("price").HasPrecision(10, 2);
            entity.Property(e => e.PricingType).HasColumnName("pricing_type").HasMaxLength(20);
            entity.HasIndex(e => new { e.ItemId, e.PricingType }).IsUnique();
            entity.HasOne(e => e.Item).WithMany(i => i.Pricing).HasForeignKey(e => e.ItemId);
        });

        builder.Entity<ItemImage>(entity =>
        {
            entity.ToTable("item_images");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.ImageId).HasColumnName("image_id");
            entity.Property(e => e.IsPrimary).HasColumnName("is_primary");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.Item).WithMany(i => i.Images).HasForeignKey(e => e.ItemId);
        });

        builder.Entity<Favorite>(entity =>
        {
            entity.ToTable("favorites");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasIndex(e => new { e.UserId, e.ItemId }).IsUnique();
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            entity.HasOne(e => e.Item).WithMany(i => i.Favorites).HasForeignKey(e => e.ItemId);
        });

        builder.Entity<SearchLog>(entity =>
        {
            entity.ToTable("search_logs");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Query).HasColumnName("query").HasMaxLength(500);
            entity.Property(e => e.CategoryId).HasColumnName("category_id");
            entity.Property(e => e.ResultsCount).HasColumnName("results_count");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        builder.Entity<UserInteraction>(entity =>
        {
            entity.ToTable("user_interactions");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.Action).HasColumnName("action").HasConversion<string>();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            entity.HasOne(e => e.Item).WithMany(i => i.Interactions).HasForeignKey(e => e.ItemId);
        });

        builder.Entity<Rental>(entity =>
        {
            entity.ToTable("rentals");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.RentalPrice).HasColumnName("rental_price").HasPrecision(10, 2);
            entity.Property(e => e.StartDate).HasColumnName("start_date");
            entity.Property(e => e.EndDate).HasColumnName("end_date");
            entity.Property(e => e.ActualReturnDate).HasColumnName("actual_return_date");
            entity.Property(e => e.LateFee).HasColumnName("late_fee").HasPrecision(10, 2);
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.DepositAmount).HasColumnName("deposit_amount").HasPrecision(10, 2);
            entity.Property(e => e.DepositStatus).HasColumnName("deposit_status").HasConversion<string>();
            entity.Property(e => e.Notes).HasColumnName("notes");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            entity.HasOne(e => e.Item).WithMany().HasForeignKey(e => e.ItemId);
            entity.HasOne(e => e.Order).WithMany(o => o.Rentals).HasForeignKey(e => e.OrderId);
        });

        builder.Entity<Order>(entity =>
        {
            entity.ToTable("orders");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.TotalAmount).HasColumnName("total_amount").HasPrecision(10, 2);
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
        });

        builder.Entity<OrderItem>(entity =>
        {
            entity.ToTable("order_items");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.Quantity).HasColumnName("quantity");
            entity.Property(e => e.PriceAtTime).HasColumnName("price_at_time").HasPrecision(10, 2);
            entity.HasOne(e => e.Order).WithMany(o => o.Items).HasForeignKey(e => e.OrderId);
            entity.HasOne(e => e.Item).WithMany().HasForeignKey(e => e.ItemId);
        });

        builder.Entity<Payment>(entity =>
        {
            entity.ToTable("payments");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.Amount).HasColumnName("amount").HasPrecision(10, 2);
            entity.Property(e => e.Method).HasColumnName("method").HasConversion<string>();
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.TransactionRef).HasColumnName("transaction_ref").HasMaxLength(100);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.Order).WithMany(o => o.Payments).HasForeignKey(e => e.OrderId);
        });

        builder.Entity<DeliveryTracking>(entity =>
        {
            entity.ToTable("delivery_tracking");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.Location).HasColumnName("location").HasMaxLength(200);
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.Order).WithMany(o => o.DeliveryTrackings).HasForeignKey(e => e.OrderId);
        });

        builder.Entity<Review>(entity =>
        {
            entity.ToTable("reviews");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.RentalId).HasColumnName("rental_id");
            entity.Property(e => e.ReviewerId).HasColumnName("reviewer_id");
            entity.Property(e => e.Rating).HasColumnName("rating");
            entity.Property(e => e.Comment).HasColumnName("comment");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasIndex(e => e.RentalId).IsUnique(); // one review per rental
            entity.HasOne(e => e.Rental).WithMany(r => r.Reviews).HasForeignKey(e => e.RentalId);
            entity.HasOne(e => e.Reviewer).WithMany().HasForeignKey(e => e.ReviewerId);
        });

        builder.Entity<ItemVerification>(entity =>
        {
            entity.ToTable("item_verifications");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.ExpertId).HasColumnName("expert_id");
            entity.Property(e => e.RentalId).HasColumnName("rental_id");
            entity.Property(e => e.CheckType).HasColumnName("check_type").HasConversion<string>();
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.Notes).HasColumnName("notes");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.Item).WithMany().HasForeignKey(e => e.ItemId);
            entity.HasOne(e => e.Expert).WithMany().HasForeignKey(e => e.ExpertId);
            entity.HasOne(e => e.Rental).WithMany(r => r.Verifications).HasForeignKey(e => e.RentalId);
        });

        builder.Entity<SystemSetting>(entity =>
        {
            entity.ToTable("system_settings");
            entity.HasKey(e => e.Key);
            entity.Property(e => e.Key).HasColumnName("key").HasMaxLength(100);
            entity.Property(e => e.Value).HasColumnName("value");
            entity.Property(e => e.Description).HasColumnName("description").HasMaxLength(500);
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
        });

        builder.Entity<WalletTransaction>(entity =>
        {
            entity.ToTable("wallet_transactions");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Amount).HasColumnName("amount").HasPrecision(14, 2);
            entity.Property(e => e.Type).HasColumnName("type").HasConversion<string>();
            entity.Property(e => e.Description).HasColumnName("description").HasMaxLength(500);
            entity.Property(e => e.RelatedRentalId).HasColumnName("related_rental_id");
            entity.Property(e => e.ReferenceId).HasColumnName("reference_id").HasMaxLength(100);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
        });

        builder.Entity<IdVerification>(entity =>
        {
            entity.ToTable("id_verifications");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.FrontImageUrl).HasColumnName("front_image_url");
            entity.Property(e => e.BackImageUrl).HasColumnName("back_image_url");
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.RejectionReason).HasColumnName("rejection_reason");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.ReviewedById).HasColumnName("reviewed_by_id");
            entity.Property(e => e.ReviewedAt).HasColumnName("reviewed_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            entity.HasOne(e => e.ReviewedBy).WithMany().HasForeignKey(e => e.ReviewedById);
        });

        builder.Entity<SupportTicket>(entity =>
        {
            entity.ToTable("support_tickets");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Type).HasColumnName("type").HasConversion<string>();
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
        });

        builder.Entity<SupportMessage>(entity =>
        {
            entity.ToTable("support_messages");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.TicketId).HasColumnName("ticket_id");
            entity.Property(e => e.SenderId).HasColumnName("sender_id");
            entity.Property(e => e.Message).HasColumnName("message");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.Ticket).WithMany(t => t.Messages).HasForeignKey(e => e.TicketId);
            entity.HasOne(e => e.Sender).WithMany().HasForeignKey(e => e.SenderId);
        });

        builder.Entity<Chat>(entity =>
        {
            entity.ToTable("chats");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.User1Id).HasColumnName("user1_id");
            entity.Property(e => e.User2Id).HasColumnName("user2_id");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            
            entity.HasIndex(e => new { e.User1Id, e.User2Id, e.ItemId }).IsUnique();
            
            entity.HasOne(e => e.User1).WithMany().HasForeignKey(e => e.User1Id).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(e => e.User2).WithMany().HasForeignKey(e => e.User2Id).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(e => e.Item).WithMany().HasForeignKey(e => e.ItemId).OnDelete(DeleteBehavior.SetNull);
        });

        builder.Entity<ChatMessage>(entity =>
        {
            entity.ToTable("chat_messages");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.ChatId).HasColumnName("chat_id");
            entity.Property(e => e.SenderId).HasColumnName("sender_id");
            entity.Property(e => e.Message).HasColumnName("message");
            entity.Property(e => e.IsRead).HasColumnName("is_read");
            entity.Property(e => e.ContextItemId).HasColumnName("context_item_id");
            entity.Property(e => e.MediaUrl).HasColumnName("media_url");
            entity.Property(e => e.MessageType).HasColumnName("message_type").HasConversion<int>();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.Chat).WithMany(c => c.Messages).HasForeignKey(e => e.ChatId);
            entity.HasOne(e => e.Sender).WithMany().HasForeignKey(e => e.SenderId).OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Notification>(entity =>
        {
            entity.ToTable("notifications");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(200);
            entity.Property(e => e.Message).HasColumnName("message");
            entity.Property(e => e.IsRead).HasColumnName("is_read");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
        });

        builder.Entity<ItemRecommendation>(entity =>
        {
            entity.ToTable("item_recommendations");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.Score).HasColumnName("score");
            entity.Property(e => e.Reason).HasColumnName("reason");
            entity.Property(e => e.Algorithm).HasColumnName("algorithm").HasMaxLength(100);
            entity.Property(e => e.IsClicked).HasColumnName("is_clicked");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            entity.HasOne(e => e.Item).WithMany().HasForeignKey(e => e.ItemId);
        });

        builder.Entity<KpiSnapshot>(entity =>
        {
            entity.ToTable("kpis_snapshots_derived");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.Date).HasColumnName("date");
            entity.Property(e => e.Period).HasColumnName("period").HasMaxLength(20);
            entity.Property(e => e.ActiveUsers).HasColumnName("active_users");
            entity.Property(e => e.NewUsers).HasColumnName("new_users");
            entity.Property(e => e.Rentals).HasColumnName("rentals");
            entity.Property(e => e.Revenue).HasColumnName("revenue").HasPrecision(14, 2);
            entity.Property(e => e.FraudRate).HasColumnName("fraud_rate");
            entity.Property(e => e.RecommendationCtr).HasColumnName("recommendation_ctr");
            entity.Property(e => e.TotalItems).HasColumnName("total_items");
            entity.Property(e => e.TotalOrders).HasColumnName("total_orders");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        builder.Entity<Permission>(entity =>
        {
            entity.ToTable("permissions");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Value).IsRequired().HasMaxLength(150);
            entity.HasIndex(e => e.Value).IsUnique();
        });

        builder.Entity<RolePermission>(entity =>
        {
            entity.ToTable("role_permissions");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.PermissionValue).IsRequired().HasMaxLength(150);
            entity.HasIndex(e => new { e.RoleId, e.PermissionValue }).IsUnique();
        });
        builder.Entity<RentalImage>(entity =>
        {
            entity.ToTable("rental_images");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            entity.Property(e => e.Type).HasConversion<int>();
            entity.HasOne(e => e.Rental).WithMany(r => r.Images).HasForeignKey(e => e.RentalId);
            entity.HasOne(e => e.Image).WithMany().HasForeignKey(e => e.ImageId);
        });
    }
}




