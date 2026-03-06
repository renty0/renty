namespace Domain.Entities;

/// <summary>Brands table — linked to items.</summary>
public class Brand
{
    public int Id { get; set; }
    public string NameAr { get; set; } = string.Empty;
    public string NameEn { get; set; } = string.Empty;

    public string? DescAr { get; set; }
    public string? DescEn { get; set; }
    
    public Guid? LogoId { get; set; }
    public virtual MediaFile? Logo { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<Item> Items { get; set; } = new List<Item>();
}
