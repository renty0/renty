namespace Domain.Entities;

/// <summary>Matches the `item_recommendations` table for user-specific recommendations.</summary>
public class ItemRecommendation
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public Guid ItemId { get; set; }
    public double Score { get; set; } = 0;
    public string? Reason { get; set; }
    public string? Algorithm { get; set; }
    public bool IsClicked { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public Item Item { get; set; } = null!;
}
