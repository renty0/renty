namespace Application.Features.Recommendations;

public record RecommendationDto(
    long Id,
    string Title,
    string? PrimaryImageUrl,
    decimal PricePerDay,
    double AverageRating,
    string? CategoryName,
    string? Reason
);
