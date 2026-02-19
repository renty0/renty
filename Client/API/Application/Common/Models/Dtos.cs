namespace Application.Common.Models;

// Product DTOs
public record ProductCategoryDto(
    int Id,
    string NameEn,
    string NameAr,
    string? DescriptionEn,
    string? DescriptionAr,
    Guid? LogoId,
    string? LogoUrl,
    int SubcategoryCount,
    DateTimeOffset Created,
    DateTimeOffset? LastModified
);

public record ProductSubcategoryDto(
    int Id,
    string NameEn,
    string NameAr,
    string? DescriptionEn,
    string? DescriptionAr,
    Guid? LogoId,
    string? LogoUrl,
    int CategoryId,
    string CategoryNameEn,
    string CategoryNameAr,
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
    string NameEn,
    string NameAr,
    string? ModelName,
    string? DescriptionEn,
    string? DescriptionAr,
    string? Color,
    string? Style,
    decimal ProductCost,
    decimal RentPricePerDay,
    string? SkuType,
    decimal? RentDiscountPrice,
    decimal EffectivePrice,
    decimal ProfitMargin,
    int SubcategoryId,
    string SubcategoryNameEn,
    string SubcategoryNameAr,
    string CategoryNameEn,
    string CategoryNameAr,
    int? BrandId,
    string? BrandNameEn,
    string? BrandNameAr,
    DateTimeOffset Created,
    DateTimeOffset? LastModified,
    List<ProductImageDto> Images
);

public record ProductListDto(
    long Id,
    string ProductSku,
    string NameEn,
    string NameAr,
    decimal RentPricePerDay,
    decimal? RentDiscountPrice,
    string? Color,
    string SubcategoryNameEn,
    string SubcategoryNameAr,
    string CategoryNameEn,
    string CategoryNameAr,
    string? BrandNameEn,
    string? BrandNameAr,
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
