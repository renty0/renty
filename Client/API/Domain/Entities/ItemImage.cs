namespace Domain.Entities;

/// <summary>
/// Matches the `item_images` table.
/// </summary>
public class ItemImage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ItemId { get; set; }
    public Guid ImageId { get; set; }
    public virtual MediaFile Image { get; set; } = null!;
    public bool IsPrimary { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Item Item { get; set; } = null!;
}
