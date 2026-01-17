namespace Application.Common.Models;

public record CategoryCountDto(string Category, int Count);

public record SalesTrendDto(
    string Period,
    int TotalOrders,
    decimal TotalRevenue,
    int TotalQuantity
);

public record CustomerDemographicsDto(
    List<CategoryCountDto> GenderBreakdown,
    List<CategoryCountDto> OccupationBreakdown,
    List<CategoryCountDto> EducationBreakdown,
    List<CategoryCountDto> MaritalStatusBreakdown
);

public record ProductPerformanceDto(
    List<CategoryCountDto> TopProducts,
    List<CategoryPerformanceDto> CategoryPerformance
);

public record CategoryPerformanceDto(
    string CategoryName,
    decimal Revenue,
    int Quantity
);

public record InventoryStatsDto(
    int TotalProducts,
    int TotalStock,
    List<CategoryCountDto> TopProducts,
    List<CategoryPerformanceDto> RevenueByCategory
);

public record ReturnAnalyticsDto(
    int TotalReturns,
    decimal TotalReturnValue,
    double ReturnRate,
    List<CategoryCountDto> ReturnReasons
);
