using Domain.Common;
using Domain.Enums;

namespace Domain.Entities;

public class RentableItem : BaseAuditableEntity
{
    public string TitleAr { get; set; } = string.Empty;
    public string TitleEn { get; set; } = string.Empty;
    public string DescAr { get; set; } = string.Empty;
    public string DescEn { get; set; } = string.Empty;
    public string? ShortDescription { get; set; }
    public decimal PricePerDay { get; set; }
    public decimal? PricePerWeek { get; set; }
    public decimal? PricePerMonth { get; set; }
    public decimal? SecurityDeposit { get; set; }
    public string? Location { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public ItemStatus Status { get; set; } = ItemStatus.Draft;
    public int MinRentalDays { get; set; } = 1;
    public int? MaxRentalDays { get; set; }
    public bool IsAvailableForDelivery { get; set; } = false;
    public decimal? DeliveryFee { get; set; }
    public string? Terms { get; set; }
    public string? CancellationPolicy { get; set; }
    public int ViewCount { get; set; } = 0;
    public double AverageRating { get; set; } = 0;
    public int TotalRatings { get; set; } = 0;

    // Foreign keys
    public long OwnerId { get; set; }
    public int? CategoryId { get; set; }
    public int? SubcategoryId { get; set; }

    // Navigation properties
    public ApplicationUser Owner { get; set; } = null!;
    public ProductCategory? Category { get; set; }
    public ProductSubcategory? Subcategory { get; set; }
    public ICollection<RentableItemImage> Images { get; set; } = new List<RentableItemImage>();
    public ICollection<RentRequest> RentRequests { get; set; } = new List<RentRequest>();

    // Approval/Rejection tracking
    public long? ApprovedById { get; set; }
    public DateTimeOffset? ApprovedAt { get; set; }
    public ApplicationUser? ApprovedBy { get; set; }

    public long? RejectedById { get; set; }
    public DateTimeOffset? RejectedAt { get; set; }
    public string? RejectionReason { get; set; }
    public ApplicationUser? RejectedBy { get; set; }
}
