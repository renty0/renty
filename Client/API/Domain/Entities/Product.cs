using Domain.Common;

namespace Domain.Entities;

public class Product : BaseAuditableEntity
{
    public string ProductSku { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string? ModelName { get; set; }
    public string? ProductDescription { get; set; }
    public string? ProductColor { get; set; }
    public string? ProductStyle { get; set; }
    public decimal ProductCost { get; set; }
    public decimal ProductPrice { get; set; }
    public string? SkuType { get; set; }
    public decimal? DiscountPrice { get; set; }

    public int ProductSubcategoryId { get; set; }

    // Navigation properties
    public ProductSubcategory Subcategory { get; set; } = null!;
    public ICollection<Sale> Sales { get; set; } = new List<Sale>();
    public ICollection<Return> Returns { get; set; } = new List<Return>();
    public ICollection<ProductImage> Images { get; set; } = new List<ProductImage>();

    // Computed property for effective price
    public decimal EffectivePrice => DiscountPrice ?? ProductPrice;

    // Computed property for profit margin
    public decimal ProfitMargin => ProductPrice > 0 ? (ProductPrice - ProductCost) / ProductPrice * 100 : 0;
}
