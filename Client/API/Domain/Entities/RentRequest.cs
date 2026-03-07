using Domain.Common;
using Domain.Enums;

namespace Domain.Entities;

public class RentRequest : BaseAuditableEntity
{
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public int TotalDays { get; set; }
    public decimal DailyRate { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal? SecurityDeposit { get; set; }
    public decimal? DeliveryFee { get; set; }
    public decimal GrandTotal { get; set; }
    public RentRequestStatus Status { get; set; } = RentRequestStatus.Pending;
    public string? Message { get; set; }
    public string? OwnerResponse { get; set; }
    public DateTimeOffset? RespondedAt { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }
    public string? CancellationReason { get; set; }
    public bool IsDeliveryRequested { get; set; } = false;
    public string? DeliveryAddress { get; set; }
    public string? PickupInstructions { get; set; }

    // Foreign keys
    public long RentableItemId { get; set; }
    public long RenterId { get; set; }

    // Navigation properties
    public RentableItem RentableItem { get; set; } = null!;
    public ApplicationUser Renter { get; set; } = null!;

    // Computed properties
    public bool CanBeCancelled => Status == RentRequestStatus.Pending || Status == RentRequestStatus.Approved;
    public bool CanBeApproved => Status == RentRequestStatus.Pending;
    public bool IsActive => Status == RentRequestStatus.Active;
}
