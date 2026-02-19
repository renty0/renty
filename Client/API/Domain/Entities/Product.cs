using Domain.Common;
using System.ComponentModel.DataAnnotations.Schema;

namespace Domain.Entities;

public class Product : BaseAuditableEntity
{
    public string ProductSku { get; set; } = string.Empty;
    public string NameEn { get; set; } = string.Empty;
    public string NameAr { get; set; } = string.Empty;
    public string? ModelName { get; set; }
    public string? DescriptionEn { get; set; }
    public string? DescriptionAr { get; set; }
    public string? Color { get; set; }
    public string? Style { get; set; }
    public decimal ProductCost { get; set; }
    public decimal RentPricePerDay { get; set; }
    public string? SkuType { get; set; }
    public decimal? RentDiscountPrice { get; set; }

    public int ProductSubcategoryId { get; set; }
    public int? BrandId { get; set; }

    // Navigation properties
    public ProductSubcategory Subcategory { get; set; } = null!;
    public Brand? Brand { get; set; }
    public ICollection<Sale> Sales { get; set; } = new List<Sale>();
    public ICollection<Return> Returns { get; set; } = new List<Return>();
    public ICollection<ProductImage> Images { get; set; } = new List<ProductImage>();

    // Computed property for effective price
    public decimal EffectivePrice => RentDiscountPrice ?? RentPricePerDay;

    // Computed property for profit margin (Needs review for Rental model compatibility)
    // For rental, profit margin is usually calculated over time, but we can keep a simple markup check if needed.
    // Simplifying for now to avoid confusion as Cost implies asset cost, not daily cost.
    public decimal ProfitMargin => RentPricePerDay > 0 ? (RentPricePerDay - (ProductCost / 365)) / RentPricePerDay * 100 : 0; 
}
