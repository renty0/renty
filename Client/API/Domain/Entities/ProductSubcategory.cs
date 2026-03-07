using System.ComponentModel.DataAnnotations.Schema;
using Domain.Common;

namespace Domain.Entities;

public class ProductSubcategory : IAuditable
{
    public int Id { get; set; }
    public string NameAr { get; set; } = string.Empty;
    public string NameEn { get; set; } = string.Empty;

    public string? DescAr { get; set; }
    public string? DescEn { get; set; }
    public int ProductCategoryId { get; set; }

    public Guid? LogoId { get; set; }
    [ForeignKey(nameof(LogoId))]
    public virtual MediaFile? Logo { get; set; }

    // Navigation properties
    public ProductCategory Category { get; set; } = null!;
    public ICollection<Product> Products { get; set; } = new List<Product>();

    // Auditing fields
    public DateTimeOffset Created { get; set; }
    public string? CreatedBy { get; set; }
    public DateTimeOffset LastModified { get; set; }
    public string? LastModifiedBy { get; set; }
}
