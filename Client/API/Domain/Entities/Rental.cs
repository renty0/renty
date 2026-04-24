using Domain.Enums;

namespace Domain.Entities;

/// <summary>Matches the `rentals` table.</summary>
public class Rental
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public Guid ItemId { get; set; }
    public Guid? OrderId { get; set; }
    public decimal RentalPrice { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime? ActualReturnDate { get; set; }
    public decimal LateFee { get; set; } = 0;
    public RentalStatus Status { get; set; } = RentalStatus.Pending;
    public decimal DepositAmount { get; set; } = 0;
    public DepositStatus DepositStatus { get; set; } = DepositStatus.Held;
    public string? Notes { get; set; }
    public string? HandoffCode { get; set; } = Guid.NewGuid().ToString("N")[..6].ToUpper();
    public bool IsHandoffVerified { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public Item Item { get; set; } = null!;
    public Order? Order { get; set; }
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<ItemVerification> Verifications { get; set; } = new List<ItemVerification>();
    public ICollection<RentalImage> Images { get; set; } = new List<RentalImage>();
}
