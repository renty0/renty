using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;


namespace Application.Features.Items;

public record ItemCategoryRef(int Id, string NameAr, string NameEn);
public record ItemSubcategoryRef(int Id, string NameAr, string NameEn);
public record ItemBrandRef(int Id, string NameAr, string NameEn);

public record ItemListDto(
    Guid Id,
    string TitleAr,
    string TitleEn,
    decimal? DailyPrice,
    string? City,
    string? PrimaryImage,
    double AvgRating,
    int ReviewCount,
    string Type,
    string? Condition,
    long? OwnerId,
    ItemCategoryRef? Category,
    ItemSubcategoryRef? Subcategory,
    ItemBrandRef? Brand
);

public record ItemPricingDto(string PricingType, decimal Price);

public record ItemImageDto(Guid Id, string ImageUrl, bool IsPrimary);

public record OwnerDto(long Id, string FirstName, string LastName, string? City, string? ProfileImageUrl, double Rating, int TotalRatings);

public record ItemDetailDto(
    Guid Id,
    string TitleAr,
    string TitleEn,
    string? DescAr,
    string? DescEn,
    string Type,
    string Status,
    string? Condition,
    decimal DefaultDeposit,
    string? Location,
    string? City,
    decimal? Lat,
    decimal? Lng,
    DateTime CreatedAt,
    OwnerDto Owner,
    List<ItemPricingDto> Pricing,
    List<ItemImageDto> Images,
    double AvgRating,
    int ReviewCount,
    ItemCategoryRef? Category,
    ItemSubcategoryRef? Subcategory,
    ItemBrandRef? Brand
);

public record GetItemsQuery(
    int? CategoryId = null,
    int? SubcategoryId = null,
    string? City = null,
    decimal? MinPrice = null,
    decimal? MaxPrice = null,
    string? Type = null,
    string? Condition = null,
    string? Sort = null,       
    string? Owner = null,  
    int Page = 1,
    int Limit = 20
) : IRequest<GetItemsResponse>;

public record GetItemsResponse(
    List<ItemListDto> Items,
    int Total,
    int Page,
    int Pages
);

public class GetItemsQueryHandler : IRequestHandler<GetItemsQuery, GetItemsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetItemsQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetItemsResponse> Handle(GetItemsQuery request, CancellationToken ct)
    {
        var isOwnerMe = string.Equals(request.Owner, "me", StringComparison.OrdinalIgnoreCase)
                        && _currentUser.Id != null;

        var query = _context.Items
            .Include(i => i.Category)
            .Include(i => i.Subcategory)
            .Include(i => i.Brand)
            .AsQueryable();


        if (isOwnerMe)
        {            query = query.Where(i => i.OwnerId == _currentUser.Id!.Value);
        }
        else
        {            query = query.Where(i => i.Status == NewItemStatus.Available);
        }

        if (request.City != null)
            query = query.Where(i => i.City == request.City);

        if (request.Type != null && Enum.TryParse<ItemType>(request.Type, true, out var itemType))
            query = query.Where(i => i.Type == itemType);

        if (request.Condition != null)
            query = query.Where(i => i.Condition == request.Condition);
        if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
        {
            query = query.Where(i => i.Pricing.Any(p =>
                p.PricingType == "daily" &&
                (!request.MinPrice.HasValue || p.Price >= request.MinPrice.Value) &&
                (!request.MaxPrice.HasValue || p.Price <= request.MaxPrice.Value)));
        }
        var projected = query.Select(i => new
        {
            Item = i,
            DailyPrice = i.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
            PrimaryImage = i.Images.Where(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault()
                ?? i.Images.Select(img => img.Image.StoragePath).FirstOrDefault(),
        });

        projected = request.Sort switch
        {
            "price_asc"  => projected.OrderBy(x => x.DailyPrice),
            "price_desc" => projected.OrderByDescending(x => x.DailyPrice),
            "newest"     => projected.OrderByDescending(x => x.Item.CreatedAt),
            _            => projected.OrderByDescending(x => x.Item.CreatedAt)
        };

        var total = await projected.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : null;

        var items = await projected
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .ToListAsync(ct);

        var resultItems = items.Select(x => new ItemListDto(
                x.Item.Id,
                x.Item.TitleAr,
                x.Item.TitleEn,
                x.DailyPrice,
                x.Item.City,
                x.PrimaryImage != null ? (!string.IsNullOrEmpty(baseUrl) ? $"{baseUrl.TrimEnd('/')}/{x.PrimaryImage.TrimStart('/')}" : "/" + x.PrimaryImage.Replace("\\", "/").TrimStart('/')) : null,
                0,  
                0,  
                x.Item.Type.ToString(),
                x.Item.Condition,
                x.Item.OwnerId,
                x.Item.Category    != null ? new ItemCategoryRef(x.Item.Category.Id, x.Item.Category.NameAr, x.Item.Category.NameEn) : null,
                x.Item.Subcategory != null ? new ItemSubcategoryRef(x.Item.Subcategory.Id, x.Item.Subcategory.NameAr, x.Item.Subcategory.NameEn) : null,
                x.Item.Brand       != null ? new ItemBrandRef(x.Item.Brand.Id, x.Item.Brand.NameAr, x.Item.Brand.NameEn) : null
            ))
            .ToList();

        return new GetItemsResponse(resultItems, total, request.Page, pages);
    }
}
