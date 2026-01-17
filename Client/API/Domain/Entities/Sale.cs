using Domain.Common;

namespace Domain.Entities;

public class Sale : BaseAuditableEntity
{
    public DateOnly OrderDate { get; set; }
    public DateOnly? StockDate { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public int OrderLineItem { get; set; }
    public int OrderQuantity { get; set; }

    // Foreign keys
    public long ProductId { get; set; }
    public long CustomerId { get; set; }
    public int TerritoryId { get; set; }

    // Navigation properties
    public Product Product { get; set; } = null!;
    public Customer Customer { get; set; } = null!;
    public Territory Territory { get; set; } = null!;
    public Calendar OrderCalendar { get; set; } = null!;
    public Calendar? StockCalendar { get; set; }

    // Computed properties
    public decimal LineTotal => OrderQuantity * (Product?.EffectivePrice ?? 0);
}
