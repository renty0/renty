using System.ComponentModel.DataAnnotations.Schema;


namespace Domain.Entities;

public class ProductCategory
{
    public int Id { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public Guid? LogoId { get; set; }
    [ForeignKey(nameof(LogoId))]
    public virtual MediaFile? Logo { get; set; }

    // Navigation properties
    public ICollection<ProductSubcategory> Subcategories { get; set; } = new List<ProductSubcategory>();
}
