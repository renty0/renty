namespace Application.Features.Brands;

public record BrandDto(
    long Id,
    string NameEn,
    string NameAr,
    string? DescriptionEn,
    string? DescriptionAr,
    string? LogoUrl
);
