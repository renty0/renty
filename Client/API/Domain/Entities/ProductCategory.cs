namespace Domain.Entities;

public class ProductCategory
{
    public int Id { get; set; }
    public string CategoryName { get; set; } = string.Empty;

    // Navigation properties
    public ICollection<ProductSubcategory> Subcategories { get; set; } = new List<ProductSubcategory>();
}
