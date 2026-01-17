using System.ComponentModel.DataAnnotations.Schema;
using Domain.Common;

namespace Domain.Entities;

public class ProductCategory : IAuditable
{
    public int Id { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public Guid? LogoId { get; set; }
    [ForeignKey(nameof(LogoId))]
    public virtual MediaFile? Logo { get; set; }

    // Navigation properties
    public ICollection<ProductSubcategory> Subcategories { get; set; } = new List<ProductSubcategory>();

    // Auditing fields
    public DateTimeOffset Created { get; set; }
    public string? CreatedBy { get; set; }
    public DateTimeOffset LastModified { get; set; }
    public string? LastModifiedBy { get; set; }
}
