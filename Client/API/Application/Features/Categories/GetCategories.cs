using Application.Common.Interfaces;
using Application.Common.Mappings;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record GetCategoriesQuery : IRequest<PaginatedList<ProductCategoryDto>>
{
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public string? SearchTerm { get; init; }
}

public class GetCategoriesQueryHandler : IRequestHandler<GetCategoriesQuery, PaginatedList<ProductCategoryDto>>
{
    private readonly IApplicationDbContext _context;

    public GetCategoriesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PaginatedList<ProductCategoryDto>> Handle(GetCategoriesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.ProductCategories
            .Include(c => c.Subcategories)
            .AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            query = query.Where(c => c.CategoryName.Contains(request.SearchTerm) || 
                                     (c.Description != null && c.Description.Contains(request.SearchTerm)));
        }

        return await query
            .OrderBy(c => c.CategoryName)
            .Select(c => new ProductCategoryDto(
                c.Id,
                c.CategoryName,
                c.Description,
                c.LogoId,
                c.Logo != null ? c.Logo.StoragePath : null,
                c.Subcategories.Count
            ))
            .PaginatedListAsync(request.PageNumber, request.PageSize, cancellationToken);
    }
}
