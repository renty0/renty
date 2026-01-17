namespace Application.Common.Models;

public record CategoryGapAnalysisDto(
    int CategoryId,
    string CategoryName,
    int UniqueProducts,
    int UniqueOrders,
    int TotalQuantitySold,
    int UniqueCustomers,
    decimal GapScore,
    string GapLevel
);

public record SubcategoryGapAnalysisDto(
    int SubcategoryId,
    string SubcategoryName,
    string CategoryName,
    int UniqueProducts,
    int UniqueOrders,
    int TotalQuantitySold,
    int UniqueCustomers,
    decimal GapScore,
    string GapLevel
);

public record TerritoryGapAnalysisDto(
    int TerritoryId,
    string Region,
    string Country,
    int CategoryId,
    string CategoryName,
    int UniqueOrders,
    int TotalQuantitySold,
    int UniqueCustomers
);

public record GapAnalysisSummaryDto(
    int TotalCategories,
    int CriticalGapsCount,
    decimal CriticalGapsPercentage,
    decimal AverageGapScore,
    string MostSevereCategory,
    decimal MostSevereScore,
    int TotalSupply,
    int TotalDemand
);

public record GapActionPlanDto(
    int CategoryId,
    string CategoryName,
    decimal GapScore,
    string GapLevel,
    List<string> OperationalActions,
    List<string> StrategicActions,
    List<string> PlatformActions,
    List<string> UserEngagementActions
);

public record GapTrendDto(
    int CategoryId,
    string CategoryName,
    decimal PreviousGapScore,
    decimal CurrentGapScore,
    decimal GapChangePercentage,
    string TrendStatus // Improving, Worsening, Stable
);
