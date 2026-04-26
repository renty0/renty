namespace Domain.Entities;

/// <summary>
/// Tracks "Remind Me" requests — when an item returns from rental, all users
/// who added a reminder will receive a notification.
/// </summary>
public class ItemReminder
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public Guid ItemId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public Item Item { get; set; } = null!;
}
