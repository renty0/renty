namespace Application.Common.Models;

public record CategoryGapAnalysisDto(
    int CategoryId,
    string CategoryNameEn,
    int UniqueProducts,
    int UniqueOrders,
    int TotalQuantitySold,
    int UniqueCustomers,
    decimal GapScore,
    string GapLevel
);

public record SubcategoryGapAnalysisDto(
    int SubcategoryId,
    string SubcategoryNameEn,
    string CategoryNameEn,
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
    string CategoryNameEn,
    int UniqueOrders,
    int TotalQuantitySold,
    int UniqueCustomers,
    decimal GapScore
);

public record GapAnalysisSummaryDto(
    int TotalCategories,
    int CriticalGapsCount,
    decimal CriticalGapsPercentage,
    decimal AverageGapScore,
    string MostSevereCategory,
    decimal MostSevereScore,
    int TotalSupply,
    int TotalDemand,
    List<CategoryGapScoreDto> CategoryGaps
);

public record GapActionPlanDto(
    int CategoryId,
    string CategoryNameEn,
    decimal GapScore,
    string GapLevel,
    List<string> OperationalActions,
    List<string> StrategicActions,
    List<string> PlatformActions,
    List<string> UserEngagementActions
);

public record GapTrendDto(
    int CategoryId,
    string CategoryNameEn,
    decimal PreviousGapScore,
    decimal CurrentGapScore,
    decimal GapChangePercentage,
    string Status // Improving, Worsening, Stable
);

public record GlobalKPIsDto(
    decimal TotalRevenue,
    int TotalOrders,
    int TotalCustomers,
    int TotalProducts,
    decimal AverageGapScore,
    int CriticalGapsCount,
    decimal OpportunityLossTotal,
    List<KpiRevenueTrendDto> RevenueTrend,
    List<CategoryGapAnalysisDto> TopGaps,
    List<GapLevelCountDto> GapLevelDistribution,
    List<SmartInsightDto> Insights
);

public record SmartInsightDto(string Title, string Message, string Severity); // Success, Info, Warning, Danger

public record DeadStockDto(
    int ProductId,
    string ProductNameEn,
    string CategoryNameEn,
    int SupplyCount,
    decimal TotalValue,
    int DaysSinceLastSale,
    string Recommendation
);

public record GapLevelCountDto(string Level, int Count);

public record OpportunityLossDto(
    int CategoryId,
    string CategoryNameEn,
    int DemandSupplyGap,
    decimal AveragePrice,
    decimal EstimatedOpportunityLoss,
    string Recommendation
);

public record GeographicHeatmapDto(
    string TerritoryName,
    List<CategoryGapScoreDto> CategoryGaps
);

public record CategoryGapScoreDto(string CategoryNameEn, decimal GapScore, string GapLevel, int SupplyCount, int DemandCount);

public record KpiRevenueTrendDto(string Month, decimal Revenue);
