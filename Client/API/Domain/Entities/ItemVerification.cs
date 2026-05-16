using Domain.Enums;

namespace Domain.Entities;

/// <summary>Matches the `item_verifications` table.</summary>
public class ItemVerification
{
    public Guid Id { get; set; }
    public Guid ItemId { get; set; }
    public long? ExpertId { get; set; }
    public Guid? RentalId { get; set; }
    public VerificationCheck CheckType { get; set; }
    public VerificationStatus Status { get; set; } = VerificationStatus.Pending;
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Item Item { get; set; } = null!;
    public ApplicationUser? Expert { get; set; }
    public Rental? Rental { get; set; }
}
