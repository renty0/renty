using Domain.Enums;

namespace Domain.Entities;

/// <summary>
/// Matches the `user_interactions` table. Tracks views, clicks, favorites, etc.
/// </summary>
public class UserInteraction
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public Guid? ItemId { get; set; }
    public InteractionAction Action { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public Item? Item { get; set; }
}
