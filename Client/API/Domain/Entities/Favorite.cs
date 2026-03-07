namespace Domain.Entities;

/// <summary>
/// Matches the `favorites` table. Unique per (user_id, item_id).
/// </summary>
public class Favorite
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public Guid ItemId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public Item Item { get; set; } = null!;
}
