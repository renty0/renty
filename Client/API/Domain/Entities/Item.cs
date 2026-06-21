using Domain.Enums;

namespace Domain.Entities;

/// <summary>
/// Matches the `items` table in the new DB schema.
/// </summary>
public class Item
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long OwnerId { get; set; }
    public string TitleAr { get; set; } = string.Empty;
    public string TitleEn { get; set; } = string.Empty;

    public string? DescAr { get; set; }
    public string? DescEn { get; set; }
    public ItemType Type { get; set; } = ItemType.Standard;
    public NewItemStatus Status { get; set; } = NewItemStatus.Available;
    public string? Condition { get; set; }   // new, like_new, good, fair
    public decimal DefaultDeposit { get; set; } = 0;
    public string? Location { get; set; }
    public string? City { get; set; }
    public decimal? Lat { get; set; }
    public decimal? Lng { get; set; }

    /// <summary>FK → product_categories.id (optional)</summary>
    public int? CategoryId { get; set; }
    /// <summary>FK → product_subcategories.id (optional)</summary>
    public int? SubcategoryId { get; set; }
    /// <summary>FK → brands.id (optional)</summary>
    public int? BrandId { get; set; }

    public bool IsForSale { get; set; } = false;
    public decimal? SalePrice { get; set; }
    public string? AdminNote { get; set; }

    /// <summary>Cancellation policy tier: flexible, moderate, strict. Defaults to flexible.</summary>
    public CancellationPolicy CancellationPolicy { get; set; } = CancellationPolicy.Flexible;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser Owner { get; set; } = null!;
    public ProductCategory? Category { get; set; }
    public ProductSubcategory? Subcategory { get; set; }
    public Brand? Brand { get; set; }
    public ICollection<ItemPricing> Pricing { get; set; } = new List<ItemPricing>();
    public ICollection<ItemImage> Images { get; set; } = new List<ItemImage>();
    public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    public ICollection<UserInteraction> Interactions { get; set; } = new List<UserInteraction>();
}
