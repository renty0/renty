using Application.Common.Interfaces;
using Application.Features.Items;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace Application.Features.PublicProfile;

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
    List<ItemListDto> Items
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
                    imageUrl = !string.IsNullOrEmpty(baseUrl) 
                        ? $"{baseUrl.TrimEnd('/')}/api/v1/media/{path}" 
                        : $"/api/v1/media/{path}";
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
                    0,
                    0,
                    i.Type.ToString(),
                    i.Condition,
                    i.OwnerId,
                    i.Category != null ? new ItemCategoryRef(i.Category.Id, i.Category.NameAr, i.Category.NameEn) : null,
                    i.Subcategory != null ? new ItemSubcategoryRef(i.Subcategory.Id, i.Subcategory.NameAr, i.Subcategory.NameEn) : null,
                    i.Brand != null ? new ItemBrandRef(i.Brand.Id, i.Brand.NameAr, i.Brand.NameEn) : null
                );
            }).ToList();

        var profileDto = new PublicProfileDto(
            user.Id,
            user.FirstName,
            user.LastName,
            !string.IsNullOrEmpty(user.ProfilePictureUrl)
                ? (!string.IsNullOrEmpty(baseUrl) ? $"{baseUrl.TrimEnd('/')}/api/v1/media/{user.ProfilePictureUrl.TrimStart('/')}" : $"/api/v1/media/{user.ProfilePictureUrl.TrimStart('/')}")
                : null,
            user.Bio,
            user.City,
            user.Country,
            user.Rating,
            user.TotalRatings,
            user.CreatedAt,
            items
        );

        return new GetPublicProfileResponse(true, null, profileDto);
    }
}
