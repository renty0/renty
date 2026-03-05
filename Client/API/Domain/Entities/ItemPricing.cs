namespace Domain.Entities;

/// <summary>
/// Matches the `item_pricing` table. pricing_type: daily | weekly | monthly
/// </summary>
public class ItemPricing
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ItemId { get; set; }
    public decimal Price { get; set; }
    public string PricingType { get; set; } = "daily"; // daily, weekly, monthly

    // Navigation
    public Item Item { get; set; } = null!;
}
