namespace Domain.Entities;

/// <summary>
/// Matches the `search_logs` table. Logs every search for gap analysis.
/// </summary>
public class SearchLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long? UserId { get; set; }
    public string Query { get; set; } = string.Empty;
    public int? CategoryId { get; set; }
    public int ResultsCount { get; set; } = 0;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser? User { get; set; }
}
