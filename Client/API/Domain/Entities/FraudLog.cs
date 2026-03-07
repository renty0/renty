namespace Domain.Entities;

/// <summary>Matches the `fraud_logs` table.</summary>
public class FraudLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public double RiskScore { get; set; } = 0;
    public string Decision { get; set; } = "safe"; // safe | flagged | blocked
    public string? Reason { get; set; }
    public string? FraudIndicators { get; set; } // JSON or pipe-delimited flags
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
}
