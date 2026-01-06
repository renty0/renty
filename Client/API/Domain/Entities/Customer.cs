using Domain.Common;

namespace Domain.Entities;

public class Customer : BaseAuditableEntity
{
    public string? Prefix { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateOnly? BirthDate { get; set; }
    public string? MaritalStatus { get; set; }
    public string? Gender { get; set; }
    public string? EmailAddress { get; set; }
    public decimal? AnnualIncome { get; set; }
    public int? TotalChildren { get; set; }
    public string? EducationLevel { get; set; }
    public string? Occupation { get; set; }
    public bool? HomeOwner { get; set; }

    // Computed property
    public string FullName => string.IsNullOrEmpty(Prefix)
        ? $"{FirstName} {LastName}".Trim()
        : $"{Prefix} {FirstName} {LastName}".Trim();

    // Navigation properties
    public ICollection<Sale> Sales { get; set; } = new List<Sale>();
}
