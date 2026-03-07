using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record GetSubcategoriesQuery(
    int? CategoryId = null, 
    int PageNumber = 1, 
    int PageSize = 10, 
    string? SearchString = null,
    string? SortBy = null,
    string? SortOrder = null) : IRequest<GetSubcategoriesResponse>;

public record GetSubcategoriesResponse(
    bool Success,
    string? Message,
    PaginatedList<ProductSubcategoryDto> Subcategories
);

public class GetSubcategoriesQueryHandler : IRequestHandler<GetSubcategoriesQuery, GetSubcategoriesResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetSubcategoriesQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetSubcategoriesResponse> Handle(GetSubcategoriesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.ProductSubcategories
            .Include(s => s.Category)
            .Include(s => s.Products)
            .Include(s => s.Logo)
            .AsNoTracking()
            .AsQueryable();

        if (request.CategoryId.HasValue)
        {
            query = query.Where(s => s.ProductCategoryId == request.CategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.SearchString))
        {
            query = query.Where(s => s.NameEn.Contains(request.SearchString) || 
                                     s.NameAr.Contains(request.SearchString));
        }

        // Apply sorting
        bool isDescending = request.SortOrder?.ToLower() == "desc";
        switch (request.SortBy?.ToLower())
        {
            case "nameen":
                query = isDescending ? query.OrderByDescending(s => s.NameEn) : query.OrderBy(s => s.NameEn);
                break;
            case "date":
                query = isDescending ? query.OrderByDescending(s => s.Created) : query.OrderBy(s => s.Created);
                break;
            default:
                query = query.OrderBy(s => s.NameEn);
                break;
        }

        var count = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;

        var dtos = items.Select(s => {
            string? logoUrl = null;
            if (s.Logo != null)
            {
                logoUrl = $"{baseUrl.TrimEnd('/')}/{s.Logo.StoragePath.Replace("\\", "/").TrimStart('/')}";
            }

            return new ProductSubcategoryDto(
                s.Id,
                s.NameAr ?? "",
                s.NameEn ?? "",
                s.DescAr,
                s.DescEn,
                s.LogoId,
                logoUrl,
                s.ProductCategoryId,
                s.Category?.NameAr ?? "",
                s.Category?.NameEn ?? "",
                s.Products.Count,
                s.Created,
                s.LastModified
            );
        }).ToList();

        var paginatedList = new PaginatedList<ProductSubcategoryDto>(dtos, count, request.PageNumber, request.PageSize);

        return new GetSubcategoriesResponse(true, null, paginatedList);
    }
}
