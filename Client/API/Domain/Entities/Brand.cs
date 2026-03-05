namespace Domain.Entities;

/// <summary>Brands table — linked to items.</summary>
public class Brand
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? LogoUrl { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<Item> Items { get; set; } = new List<Item>();
}
