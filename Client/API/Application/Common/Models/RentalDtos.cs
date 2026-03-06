using Domain.Enums;

namespace Application.Common.Models;

// RentableItem DTOs
public record RentableItemDto(
    long Id,
    string TitleAr,
    string TitleEn,
    string DescAr,
    string DescEn,
    string? ShortDescription,
    decimal PricePerDay,
    decimal? PricePerWeek,
    decimal? PricePerMonth,
    decimal? SecurityDeposit,
    string? Location,
    string? City,
    string? Country,
    double? Latitude,
    double? Longitude,
    string Status,
    int MinRentalDays,
    int? MaxRentalDays,
    bool IsAvailableForDelivery,
    decimal? DeliveryFee,
    string? Terms,
    string? CancellationPolicy,
    int ViewCount,
    double AverageRating,
    int TotalRatings,
    long OwnerId,
    string OwnerName,
    int? CategoryId,
    string? CategoryNameEn,
    int? SubcategoryId,
    string? SubcategoryNameEn,
    List<RentableItemImageDto> Images,
    DateTimeOffset Created
);

public record RentableItemListDto(
    long Id,
    string TitleAr,
    string TitleEn,
    string? ShortDescription,
    decimal PricePerDay,
    string? City,
    string? Country,
    string Status,
    double AverageRating,
    int TotalRatings,
    string? PrimaryImageUrl,
    string OwnerName,
    string? CategoryNameEn
);

public record RentableItemImageDto(
    long Id,
    string ImageUrl,
    string? ThumbnailUrl,
    string? AltText,
    int DisplayOrder,
    bool IsPrimary
);

// RentRequest DTOs
public record RentRequestDto(
    long Id,
    DateOnly StartDate,
    DateOnly EndDate,
    int TotalDays,
    decimal DailyRate,
    decimal TotalAmount,
    decimal? SecurityDeposit,
    decimal? DeliveryFee,
    decimal GrandTotal,
    string Status,
    string? Message,
    string? OwnerResponse,
    DateTimeOffset? RespondedAt,
    DateTimeOffset? CancelledAt,
    string? CancellationReason,
    bool IsDeliveryRequested,
    string? DeliveryAddress,
    string? PickupInstructions,
    long RentableItemId,
    string RentableItemTitleAr,
    string RentableItemTitleEn,
    string? RentableItemImageUrl,
    long RenterId,
    string RenterName,
    string? RenterEmail,
    long OwnerId,
    string OwnerName,
    DateTimeOffset Created
);

public record RentRequestListDto(
    long Id,
    DateOnly StartDate,
    DateOnly EndDate,
    int TotalDays,
    decimal GrandTotal,
    string Status,
    string RentableItemTitleEn,
    string? RentableItemImageUrl,
    string RenterName,
    string OwnerName,
    DateTimeOffset Created
);

public record CreateRentRequestDto(
    long RentableItemId,
    DateOnly StartDate,
    DateOnly EndDate,
    string? Message,
    bool IsDeliveryRequested,
    string? DeliveryAddress
);

// Owner Dashboard DTOs
public record OwnerDashboardDto(
    int TotalItems,
    int AvailableItems,
    int RentedItems,
    int PendingRequests,
    int ActiveRentals,
    decimal TotalEarnings,
    List<RentRequestListDto> RecentRequests
);

// Renter Dashboard DTOs
public record RenterDashboardDto(
    int TotalRequests,
    int PendingRequests,
    int ActiveRentals,
    int CompletedRentals,
    decimal TotalSpent,
    List<RentRequestListDto> RecentRequests
);
