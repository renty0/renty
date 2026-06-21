using Domain.Enums;

namespace Domain.Entities;

/// <summary>
/// Matches the `rental_extensions` table from System Design v2.0.
/// Renter requests extra days; owner approves or rejects.
/// </summary>
public class RentalExtension
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RentalId { get; set; }
    public long RequestedBy { get; set; }  // renter user ID
    public DateTime NewEndDate { get; set; }
    public int ExtraDays { get; set; }
    public decimal ExtraCost { get; set; }
    public ExtensionStatus Status { get; set; } = ExtensionStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Rental Rental { get; set; } = null!;
    public ApplicationUser Requester { get; set; } = null!;
}
