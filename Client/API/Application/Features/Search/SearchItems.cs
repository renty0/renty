using Application.Common.Interfaces;
using Application.Features.Items;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace Application.Features.Search;

public record SearchItemsQuery(
    string Q,
    int? CategoryId = null,
    string? City = null,
    int Page = 1,
    int Limit = 20
) : IRequest<SearchItemsResponse>;

public record SearchItemsResponse(
    List<ItemListDto> Items,
    int Total,
    int Page,
    int Pages
);

public class SearchItemsQueryHandler : IRequestHandler<SearchItemsQuery, SearchItemsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public SearchItemsQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<SearchItemsResponse> Handle(SearchItemsQuery request, CancellationToken ct)
    {
        var term = request.Q.Trim().ToLower();

        var query = _context.Items
            .Include(i => i.Category)
            .Include(i => i.Subcategory)
            .Include(i => i.Brand)
            .Where(i => i.Status == NewItemStatus.Available)
            .Where(i => i.TitleEn.ToLower().Contains(term) || i.TitleAr.ToLower().Contains(term))
            .AsQueryable();

        if (request.City != null)
            query = query.Where(i => i.City == request.City);

        if (request.CategoryId != null)
            query = query.Where(i => i.CategoryId == request.CategoryId);

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var rawItems = await query
            .OrderByDescending(i => i.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(i => new
            {
                i.Id,
                i.TitleAr,
                i.TitleEn,
                DailyPrice = i.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                i.City,
                PrimaryImage = i.Images.Where(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault()
                    ?? i.Images.Select(img => img.Image.StoragePath).FirstOrDefault(),
                TypeStr = i.Type.ToString(),
                i.Condition,
                OwnerId = (long?)i.OwnerId,
                i.IsForSale,
                i.SalePrice,
                StatusStr = i.Status.ToString(),
                i.CreatedAt,
                i.Category,
                i.Subcategory,
                i.Brand
            })
            .ToListAsync(ct);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : null;

        var items = rawItems.Select(i => new ItemListDto(
            i.Id,
            i.TitleAr,
            i.TitleEn,
            i.DailyPrice,
            i.City,
            i.PrimaryImage != null
                ? (i.PrimaryImage.StartsWith("http://") || i.PrimaryImage.StartsWith("https://")
                    ? i.PrimaryImage
                    : !string.IsNullOrEmpty(baseUrl) ? $"{baseUrl.TrimEnd('/')}/{i.PrimaryImage.TrimStart('/')}" : "/" + i.PrimaryImage.Replace("\\", "/").TrimStart('/'))
                : null,
            0, 0, // AvgRating, ReviewCount
            i.TypeStr,
            i.Condition,
            i.OwnerId,
            i.IsForSale,
            i.SalePrice,
            i.StatusStr,
            i.CreatedAt,
            i.Category    != null ? new ItemCategoryRef(i.Category.Id, i.Category.NameAr, i.Category.NameEn) : null,
            i.Subcategory != null ? new ItemSubcategoryRef(i.Subcategory.Id, i.Subcategory.NameAr, i.Subcategory.NameEn) : null,
            i.Brand       != null ? new ItemBrandRef(i.Brand.Id, i.Brand.NameAr, i.Brand.NameEn) : null
        )).ToList();

        // Log search (fire-and-forget style, don't fail search if logging fails)
        try
        {
            _context.SearchLogs.Add(new SearchLog
            {
                UserId = _currentUser.Id,
                Query = request.Q,
                CategoryId = request.CategoryId,
                ResultsCount = total,
                CreatedAt = DateTime.UtcNow
            });
            await _context.SaveChangesAsync(ct);
        }
        catch { /* swallow logging errors */ }

        return new SearchItemsResponse(items, total, request.Page, pages);
    }
}
