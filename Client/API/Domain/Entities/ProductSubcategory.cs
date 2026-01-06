namespace Domain.Entities;

public class ProductSubcategory
{
    public int Id { get; set; }
    public string SubcategoryName { get; set; } = string.Empty;
    public int ProductCategoryId { get; set; }

    // Navigation properties
    public ProductCategory Category { get; set; } = null!;
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
