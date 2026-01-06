using Domain.Common;

namespace Domain.Entities;

public class RentableItemImage : BaseEntity
{
    public string ImageUrl { get; set; } = string.Empty;
    public string? ThumbnailUrl { get; set; }
    public string? AltText { get; set; }
    public int DisplayOrder { get; set; } = 0;
    public bool IsPrimary { get; set; } = false;

    // Foreign key
    public long RentableItemId { get; set; }

    // Navigation property
    public RentableItem RentableItem { get; set; } = null!;
}
