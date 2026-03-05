using Domain.Enums;

namespace Domain.Entities;

/// <summary>Matches the `delivery_tracking` table.</summary>
public class DeliveryTracking
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrderId { get; set; }
    public DeliveryStatus Status { get; set; } = DeliveryStatus.Processing;
    public string? Location { get; set; }
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Order Order { get; set; } = null!;
}
