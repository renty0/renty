namespace Application.Common.Models;

// Product DTOs
public record ProductCategoryDto(
    int Id,
    string NameAr,
    string NameEn,
    string? DescAr,
    string? DescEn,
    Guid? LogoId,
    string? LogoUrl,
    int SubcategoryCount,
    DateTimeOffset Created,
    DateTimeOffset? LastModified
);

public record ProductSubcategoryDto(
    int Id,
    string NameAr,
    string NameEn,
    string? DescAr,
    string? DescEn,
    Guid? LogoId,
    string? LogoUrl,
    int CategoryId,
    string CategoryNameAr,
    string CategoryNameEn,
    int ProductCount,
    DateTimeOffset Created,
    DateTimeOffset? LastModified
);

public record ProductImageDto(
    long Id,
    string ImageUrl,
    bool IsPrimary,
    int DisplayOrder
);

public record ProductDto(
    long Id,
    string ProductSku,
    string NameAr,
    string NameEn,
    string? ModelName,
    string DescAr,
    string DescEn,
    string? ProductColor,
    string? ProductStyle,
    decimal ProductCost,
    decimal ProductPrice,
    string? SkuType,
    decimal? DiscountPrice,
    decimal EffectivePrice,
    decimal ProfitMargin,
    int SubcategoryId,
    string SubcategoryNameAr,
    string SubcategoryNameEn,
    string CategoryNameAr,
    string CategoryNameEn,
    DateTimeOffset Created,
    DateTimeOffset? LastModified,
    List<ProductImageDto> Images
);

public record ProductListDto(
    long Id,
    string ProductSku,
    string NameAr,
    string NameEn,
    decimal ProductPrice,
    decimal? DiscountPrice,
    string? ProductColor,
    string SubcategoryNameAr,
    string SubcategoryNameEn,
    string CategoryNameAr,
    string CategoryNameEn,
    DateTimeOffset Created,
    DateTimeOffset? LastModified,
    string? PrimaryImageUrl
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
    bool? HomeOwner,
    string? DomainName
);

public record CustomerListDto(
    long Id,
    string FullName,
    string? EmailAddress,
    string? Gender,
    string? Occupation,
    string? DomainName
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
    string ProductNameAr,
    string ProductNameEn,
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
    string ProductNameEn,
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
    string ProductNameEn,
    int TerritoryId,
    string TerritoryRegion,
    string TerritoryCountry,
    decimal ReturnValue
);

public record ReturnListDto(
    long Id,
    DateOnly ReturnDate,
    int ReturnQuantity,
    string ProductNameEn,
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
    string ProductNameEn,
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
