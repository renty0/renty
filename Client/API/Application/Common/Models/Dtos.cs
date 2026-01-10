namespace Application.Common.Models;

// Product DTOs
public record ProductCategoryDto(
    int Id,
    string CategoryName,
    string Description,
    Guid? LogoId,
    string? LogoUrl,
    int SubcategoryCount
);

public record ProductSubcategoryDto(
    int Id,
    string SubcategoryName,
    int CategoryId,
    string CategoryName,
    int ProductCount
);

public record ProductDto(
    long Id,
    string ProductSku,
    string ProductName,
    string? ModelName,
    string? ProductDescription,
    string? ProductColor,
    string? ProductStyle,
    decimal ProductCost,
    decimal ProductPrice,
    string? SkuType,
    decimal? DiscountPrice,
    decimal EffectivePrice,
    decimal ProfitMargin,
    int SubcategoryId,
    string SubcategoryName,
    string CategoryName
);

public record ProductListDto(
    long Id,
    string ProductSku,
    string ProductName,
    decimal ProductPrice,
    decimal? DiscountPrice,
    string? ProductColor,
    string SubcategoryName,
    string CategoryName
);

// Calendar DTOs
public record CalendarDto(
    DateOnly Date,
    string DayName,
    string MonthName,
    int Month,
    int Year,
    int Quarter,
    bool IsWeekend
);

// Territory DTOs
public record TerritoryDto(
    int Id,
    string Region,
    string Country,
    string Continent
);

// Customer DTOs
public record CustomerDto(
    long Id,
    string? Prefix,
    string FirstName,
    string LastName,
    string FullName,
    DateOnly? BirthDate,
    string? MaritalStatus,
    string? Gender,
    string? EmailAddress,
    decimal? AnnualIncome,
    int? TotalChildren,
    string? EducationLevel,
    string? Occupation,
    bool? HomeOwner
);

public record CustomerListDto(
    long Id,
    string FullName,
    string? EmailAddress,
    string? Gender,
    string? Occupation
);

// Sale DTOs
public record SaleDto(
    long Id,
    DateOnly OrderDate,
    DateOnly? StockDate,
    string OrderNumber,
    int OrderLineItem,
    int OrderQuantity,
    long ProductId,
    string ProductName,
    decimal ProductPrice,
    long CustomerId,
    string CustomerName,
    int TerritoryId,
    string TerritoryRegion,
    string TerritoryCountry,
    decimal LineTotal
);

public record SaleListDto(
    long Id,
    DateOnly OrderDate,
    string OrderNumber,
    int OrderQuantity,
    string ProductName,
    string CustomerName,
    decimal LineTotal
);

// Return DTOs
public record ReturnDto(
    long Id,
    DateOnly ReturnDate,
    int ReturnQuantity,
    string? ReturnReason,
    long ProductId,
    string ProductName,
    int TerritoryId,
    string TerritoryRegion,
    string TerritoryCountry,
    decimal ReturnValue
);

public record ReturnListDto(
    long Id,
    DateOnly ReturnDate,
    int ReturnQuantity,
    string ProductName,
    string TerritoryRegion
);

// Analytics DTOs
public record SalesSummaryDto(
    decimal TotalRevenue,
    int TotalOrders,
    int TotalQuantity,
    decimal AverageOrderValue
);

public record SalesByPeriodDto(
    int Year,
    int? Month,
    int? Quarter,
    decimal Revenue,
    int OrderCount,
    int Quantity
);

public record TopProductDto(
    long ProductId,
    string ProductName,
    int QuantitySold,
    decimal Revenue
);

public record TopCustomerDto(
    long CustomerId,
    string CustomerName,
    int OrderCount,
    decimal TotalSpent
);

public record ReturnsSummaryDto(
    int TotalReturns,
    int TotalQuantityReturned,
    decimal TotalReturnValue,
    decimal ReturnRate
);
