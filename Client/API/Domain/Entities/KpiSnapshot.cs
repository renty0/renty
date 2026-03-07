namespace Domain.Entities;

/// <summary>Matches the `kpis_snapshots_derived` view/table.</summary>
public class KpiSnapshot
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime Date { get; set; }
    public string Period { get; set; } = "daily"; // daily, weekly, monthly
    public int ActiveUsers { get; set; } = 0;
    public int NewUsers { get; set; } = 0;
    public int Rentals { get; set; } = 0;
    public decimal Revenue { get; set; } = 0;
    public double FraudRate { get; set; } = 0;
    public double RecommendationCtr { get; set; } = 0;
    public int TotalItems { get; set; } = 0;
    public int TotalOrders { get; set; } = 0;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
