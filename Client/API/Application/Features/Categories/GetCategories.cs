using Application.Common.Interfaces;
using Application.Common.Mappings;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record GetCategoriesQuery : IRequest<PaginatedList<ProductCategoryDto>>
{
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public string? SearchTerm { get; init; }
    public string? SortBy { get; init; }
    public string? SortOrder { get; init; }
}

public class GetCategoriesQueryHandler : IRequestHandler<GetCategoriesQuery, PaginatedList<ProductCategoryDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetCategoriesQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<PaginatedList<ProductCategoryDto>> Handle(GetCategoriesQuery request, CancellationToken cancellationToken)
    {
        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;

        var pageNumber = request.PageNumber < 1 ? 1 : request.PageNumber;
        var pageSize = request.PageSize < 1 ? 10 : request.PageSize;

        var query = _context.ProductCategories
            .AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            query = query.Where(c => c.NameEn.Contains(request.SearchTerm) || 
                                     c.NameAr.Contains(request.SearchTerm));
        }

        // Apply sorting
        bool isDescending = request.SortOrder?.ToLower() == "desc";
        switch (request.SortBy?.ToLower())
        {
            case "nameen":
                query = isDescending ? query.OrderByDescending(c => c.NameEn) : query.OrderBy(c => c.NameEn);
                break;
            case "date":
                query = isDescending ? query.OrderByDescending(c => c.Created) : query.OrderBy(c => c.Created);
                break;
            default:
                query = query.OrderBy(c => c.NameEn);
                break;
        }

        var count = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .Select(c => new
            {
                c.Id,
                c.NameAr,
                c.NameEn,
                c.DescAr,
                c.DescEn,
                c.LogoId,
                c.Created,
                c.LastModified
            })
            .ToListAsync(cancellationToken);

        var categoryIds = items.Select(c => c.Id).ToList();
        var logoIds = items.Where(c => c.LogoId != null).Select(c => c.LogoId!.Value).Distinct().ToList();
        var logoPathsByFileId = logoIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await _context.MediaFiles
                .AsNoTracking()
                .Where(m => logoIds.Contains(m.Id))
                .ToDictionaryAsync(m => m.Id, m => m.StoragePath, cancellationToken);
        var logoPathByCategoryId = items
            .Where(c => c.LogoId != null && logoPathsByFileId.ContainsKey(c.LogoId!.Value))
            .ToDictionary(c => c.Id, c => logoPathsByFileId[c.LogoId!.Value]);
        var subcategoryCounts = await _context.ProductSubcategories
            .AsNoTracking()
            .Where(s => categoryIds.Contains(s.ProductCategoryId))
            .GroupBy(s => s.ProductCategoryId)
            .Select(g => new { CategoryId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.CategoryId, x => x.Count, cancellationToken);

        var baseUrlNormalized = string.IsNullOrEmpty(baseUrl) ? "" : baseUrl.TrimEnd('/');

        var dtos = new List<ProductCategoryDto>();
        foreach (var c in items)
        {
            var logoPath = logoPathByCategoryId.GetValueOrDefault(c.Id);
            var logoUrl = !string.IsNullOrEmpty(logoPath)
                ? $"{baseUrlNormalized}/{logoPath.Replace("\\", "/").TrimStart('/')}"
                : (string?)null;
            var subcategoryCount = subcategoryCounts.GetValueOrDefault(c.Id, 0);
            dtos.Add(new ProductCategoryDto(
                c.Id,
                c.NameAr ?? "",
                c.NameEn ?? "",
                c.DescAr,
                c.DescEn,
                c.LogoId,
                logoUrl,
                subcategoryCount,
                c.Created,
                c.LastModified
            ));
        }

        var paginatedItems = new PaginatedList<ProductCategoryDto>(dtos, count, pageNumber, pageSize);

        return paginatedItems;
    }
}
