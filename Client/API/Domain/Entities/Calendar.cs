namespace Domain.Entities;

public class Calendar
{
    public DateOnly Date { get; set; }
    public string DayName { get; set; } = string.Empty;
    public DateOnly StartOfWeek { get; set; }
    public DateOnly StartOfMonth { get; set; }
    public DateOnly StartOfQuarter { get; set; }
    public string MonthName { get; set; } = string.Empty;
    public int Month { get; set; }
    public DateOnly StartOfYear { get; set; }
    public int Year { get; set; }
    public int Quarter { get; set; }
    public int DayOfWeek { get; set; }
    public int DayOfMonth { get; set; }
    public int DayOfYear { get; set; }
    public int WeekOfYear { get; set; }
    public bool IsWeekend { get; set; }

    // Navigation properties
    public ICollection<Sale> OrderSales { get; set; } = new List<Sale>();
    public ICollection<Sale> StockSales { get; set; } = new List<Sale>();
    public ICollection<Return> Returns { get; set; } = new List<Return>();
}
