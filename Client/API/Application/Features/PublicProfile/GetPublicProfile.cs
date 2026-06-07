using Application.Common.Interfaces;
using Application.Features.Items;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace Application.Features.PublicProfile;

public record ReviewDto(
    Guid Id,
    int Rating,
    string? Comment,
    string ReviewerName,
    string? ReviewerImage,
    DateTime CreatedAt,
    string Role
);

public record PublicProfileDto(
    long Id,
    string FirstName,
    string LastName,
    string? ProfilePictureUrl,
    string? Bio,
    string? City,
    string? Country,
    double Rating,
    int TotalRatings,
    DateTimeOffset JoinedAt,
    List<ItemListDto> Items,
    List<ReviewDto> Reviews
);

public record GetPublicProfileQuery(long UserId) : IRequest<GetPublicProfileResponse>;
public record GetPublicProfileResponse(bool Success, string? Error, PublicProfileDto? Profile);

public class GetPublicProfileQueryHandler : IRequestHandler<GetPublicProfileQuery, GetPublicProfileResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetPublicProfileQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetPublicProfileResponse> Handle(GetPublicProfileQuery request, CancellationToken ct)
    {
        var user = await _context.Users
            .Include(u => u.Items)
                .ThenInclude(i => i.Images)
                    .ThenInclude(img => img.Image)
            .Include(u => u.Items)
                .ThenInclude(i => i.Category)
            .Include(u => u.Items)
                .ThenInclude(i => i.Subcategory)
            .Include(u => u.Items)
                .ThenInclude(i => i.Brand)
            .Include(u => u.Items)
                .ThenInclude(i => i.Pricing)
            .FirstOrDefaultAsync(u => u.Id == request.UserId, ct);

        if (user == null)
            return new GetPublicProfileResponse(false, "User not found.", null);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : null;

        var items = user.Items
            .Where(i => i.Status == Domain.Enums.NewItemStatus.Available)
            .Select(i => {
                var primaryImage = i.Images.FirstOrDefault(img => img.IsPrimary) ?? i.Images.FirstOrDefault();
                string? imageUrl = null;
                if (primaryImage?.Image != null)
                {
                    var path = primaryImage.Image.StoragePath.Replace("\\", "/").TrimStart('/');
                    imageUrl = path.StartsWith("http://") || path.StartsWith("https://")
                        ? path
                        : (!string.IsNullOrEmpty(baseUrl) 
                            ? $"{baseUrl.TrimEnd('/')}/{path}" 
                            : $"/{path}");
                }

                var dailyPrice = i.Pricing.FirstOrDefault(p => p.PricingType == "daily")?.Price 
                               ?? i.Pricing.FirstOrDefault()?.Price 
                               ?? 0;

                return new ItemListDto(
                    i.Id,
                    i.TitleAr,
                    i.TitleEn,
                    dailyPrice,
                    i.City,
                    imageUrl,
                    0, // AvgRating
                    0, // ReviewCount
                    i.Type.ToString(),
                    i.Condition,
                    i.OwnerId,
                    i.IsForSale,
                    i.SalePrice,
                    i.Status.ToString(),
                    i.CreatedAt,
                    i.Category != null ? new ItemCategoryRef(i.Category.Id, i.Category.NameAr, i.Category.NameEn) : null,
                    i.Subcategory != null ? new ItemSubcategoryRef(i.Subcategory.Id, i.Subcategory.NameAr, i.Subcategory.NameEn) : null,
                    i.Brand != null ? new ItemBrandRef(i.Brand.Id, i.Brand.NameAr, i.Brand.NameEn) : null
                );
            }).ToList();

        var reviews = await _context.Reviews
            .Include(r => r.Reviewer)
            .Include(r => r.Rental)
            .Where(r => r.Rental.Item.OwnerId == request.UserId)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new ReviewDto(
                r.Id,
                r.Rating,
                r.Comment,
                r.Reviewer.FirstName + " " + r.Reviewer.LastName,
                !string.IsNullOrEmpty(r.Reviewer.ProfilePictureUrl) 
                    ? (r.Reviewer.ProfilePictureUrl.StartsWith("http://") || r.Reviewer.ProfilePictureUrl.StartsWith("https://")
                        ? r.Reviewer.ProfilePictureUrl
                        : (!string.IsNullOrEmpty(baseUrl) ? $"{baseUrl.TrimEnd('/')}/{r.Reviewer.ProfilePictureUrl.TrimStart('/')}" : "/" + r.Reviewer.ProfilePictureUrl.TrimStart('/')))
                    : null,
                r.CreatedAt,
                "owner"
            ))
            .ToListAsync(ct);

        var profileDto = new PublicProfileDto(
            user.Id,
            user.FirstName,
            user.LastName,
            !string.IsNullOrEmpty(user.ProfilePictureUrl)
                ? (user.ProfilePictureUrl.StartsWith("http://") || user.ProfilePictureUrl.StartsWith("https://")
                    ? user.ProfilePictureUrl
                    : (!string.IsNullOrEmpty(baseUrl) ? $"{baseUrl.TrimEnd('/')}/{user.ProfilePictureUrl.TrimStart('/')}" : "/" + user.ProfilePictureUrl.TrimStart('/')))
                : null,
            user.Bio,
            user.City,
            user.Country,
            user.Rating,
            user.TotalRatings,
            user.CreatedAt,
            items,
            reviews
        );

        return new GetPublicProfileResponse(true, null, profileDto);
    }
}
