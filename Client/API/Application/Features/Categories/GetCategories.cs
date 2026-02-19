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
            var term = request.SearchTerm;
            query = query.Where(c => c.NameEn.Contains(term) || 
                                     c.NameAr.Contains(term) ||
                                     (c.DescriptionEn != null && c.DescriptionEn.Contains(term)) ||
                                     (c.DescriptionAr != null && c.DescriptionAr.Contains(term)));
        }

        // Apply sorting
        bool isDescending = request.SortOrder?.ToLower() == "desc";
        switch (request.SortBy?.ToLower())
        {
            case "name":
                query = isDescending ? query.OrderByDescending(c => c.NameEn) : query.OrderBy(c => c.NameEn);
                break;
            case "date":
                query = isDescending ? query.OrderByDescending(c => c.Created) : query.OrderBy(c => c.Created);
                break;
            default:
                query = query.OrderBy(c => c.NameEn);
                break;
        }

        // We can't project directly to DTO easily with pagination helper if DTO has complex logic unless we project to anonymous type first
        var paginatedItems = await query
            .Select(c => new
            {
                c.Id,
                c.NameEn,
                c.NameAr,
                c.DescriptionEn,
                c.DescriptionAr,
                c.LogoId,
                Logo = c.Logo, // Grab the logo object to get path
                SubcategoryCount = c.Subcategories.Count,
                c.Created,
                c.LastModified
            })
            .PaginatedListAsync(request.PageNumber, request.PageSize, cancellationToken);

        var dtos = paginatedItems.Items.Select(c => 
        {
            string? logoUrl = null;
            if (c.Logo != null)
            {
                 logoUrl = $"{baseUrl.TrimEnd('/')}/{c.Logo.StoragePath.Replace("\\", "/").TrimStart('/')}";
            }

            return new ProductCategoryDto(
                c.Id, 
                c.NameEn, 
                c.NameAr, 
                c.DescriptionEn, 
                c.DescriptionAr, 
                c.LogoId, 
                logoUrl,
                c.SubcategoryCount,
                c.Created,
                c.LastModified
            );
        }).ToList(); // Convert to list

        // Create a new PaginatedList with the projected DTOs
        // Note: PaginatedList constructor might be internal or specific, let's check how it's used. 
        // original code was: return new PaginatedList<ProductCategoryDto>(dtos, paginatedItems.TotalCount, paginatedItems.PageNumber, request.PageSize);
        // Wait, PaginatedList constructor takes (items, count, pageNumber, pageSize). The items need to be the list.
        
        return new PaginatedList<ProductCategoryDto>(dtos, paginatedItems.TotalCount, paginatedItems.PageNumber, request.PageSize);
    }
}
