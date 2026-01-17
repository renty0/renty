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

        var query = _context.ProductCategories
            .AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            query = query.Where(c => c.CategoryName.Contains(request.SearchTerm) || 
                                     (c.Description != null && c.Description.Contains(request.SearchTerm)));
        }

        // Apply sorting
        bool isDescending = request.SortOrder?.ToLower() == "desc";
        switch (request.SortBy?.ToLower())
        {
            case "name":
                query = isDescending ? query.OrderByDescending(c => c.CategoryName) : query.OrderBy(c => c.CategoryName);
                break;
            case "date":
                query = isDescending ? query.OrderByDescending(c => c.Created) : query.OrderBy(c => c.Created);
                break;
            default:
                query = query.OrderBy(c => c.CategoryName);
                break;
        }

        var paginatedItems = await query
            .Select(c => new
            {
                c.Id,
                c.CategoryName,
                c.Description,
                c.LogoId,
                LogoStoragePath = c.Logo != null ? c.Logo.StoragePath : null,
                SubcategoryCount = c.Subcategories.Count,
                c.Created,
                c.LastModified
            })
            .PaginatedListAsync(request.PageNumber, request.PageSize, cancellationToken);

        var dtos = paginatedItems.Items.Select(c => new ProductCategoryDto(
            c.Id, 
            c.CategoryName, 
            c.Description, 
            c.LogoId, 
            !string.IsNullOrEmpty(c.LogoStoragePath) 
                ? $"{baseUrl.TrimEnd('/')}/{c.LogoStoragePath.Replace("\\", "/").TrimStart('/')}" 
                : null,
            c.SubcategoryCount,
            c.Created,
            c.LastModified
        )).ToList();

        return new PaginatedList<ProductCategoryDto>(dtos, paginatedItems.TotalCount, paginatedItems.PageNumber, request.PageSize);
    }
}
