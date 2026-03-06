using Domain.Common;

using System.ComponentModel.DataAnnotations.Schema;

namespace Domain.Entities;

public class RentableItemImage : BaseEntity
{
    public Guid ImageId { get; set; }
    [ForeignKey(nameof(ImageId))]
    public virtual MediaFile? Image { get; set; }
    public string? ThumbnailUrl { get; set; }
    public string? AltText { get; set; }
    public int DisplayOrder { get; set; } = 0;
    public bool IsPrimary { get; set; } = false;

    // Foreign key
    public long RentableItemId { get; set; }

    // Navigation property
    public RentableItem RentableItem { get; set; } = null!;
}
