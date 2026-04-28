using Application.Common.Interfaces;
using Application.Features.Items;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

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

    public SearchItemsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
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

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var items = await query
            .OrderByDescending(i => i.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(i => new ItemListDto(
                i.Id,
                i.TitleAr,
                i.TitleEn,
                i.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                i.City,
                i.Images.Where(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault()
                    ?? i.Images.Select(img => img.Image.StoragePath).FirstOrDefault(),
                0, 0, // AvgRating, ReviewCount
                i.Type.ToString(),
                i.Condition,
                (long?)i.OwnerId,
                i.IsForSale,
                i.SalePrice,
                i.Category    != null ? new ItemCategoryRef(i.Category.Id, i.Category.NameAr, i.Category.NameEn) : null,
                i.Subcategory != null ? new ItemSubcategoryRef(i.Subcategory.Id, i.Subcategory.NameAr, i.Subcategory.NameEn) : null,
                i.Brand       != null ? new ItemBrandRef(i.Brand.Id, i.Brand.NameAr, i.Brand.NameEn) : null
            ))
            .ToListAsync(ct);

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
