namespace Application.Features.Recommendations;

public record RecommendationDto(
    long Id,
    string TitleAr,
    string TitleEn,
    string? PrimaryImageUrl,
    decimal PricePerDay,
    double AverageRating,
    string? CategoryNameEn,
    string? Reason
);
