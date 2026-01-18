
namespace Domain.Entities;

public class GapAnalysisResult
{
    public int Id { get; set; }
    public string Category { get; set; } = string.Empty;
    public int Supply { get; set; }
    public int Demand { get; set; }
    public double GapScore { get; set; }
    public string GapStatus { get; set; } = string.Empty;
    public double NormalizedGap { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid BatchId { get; set; }
}
