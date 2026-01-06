using Domain.Common;

namespace Domain.Entities;

public class Return : BaseAuditableEntity
{
    public DateOnly ReturnDate { get; set; }
    public int ReturnQuantity { get; set; }
    public string? ReturnReason { get; set; }

    // Foreign keys
    public long ProductId { get; set; }
    public int TerritoryId { get; set; }

    // Navigation properties
    public Product Product { get; set; } = null!;
    public Territory Territory { get; set; } = null!;
    public Calendar ReturnCalendar { get; set; } = null!;

    // Computed property for return value
    public decimal ReturnValue => ReturnQuantity * (Product?.EffectivePrice ?? 0);
}
