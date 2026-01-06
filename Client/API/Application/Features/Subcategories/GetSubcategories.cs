using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record GetSubcategoriesQuery(int? CategoryId = null) : IRequest<GetSubcategoriesResponse>;

public record GetSubcategoriesResponse(
    bool Success,
    string? Message,
    List<ProductSubcategoryDto> Subcategories
);

public class GetSubcategoriesQueryHandler : IRequestHandler<GetSubcategoriesQuery, GetSubcategoriesResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSubcategoriesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetSubcategoriesResponse> Handle(GetSubcategoriesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.ProductSubcategories
            .Include(s => s.Category)
            .Include(s => s.Products)
            .AsQueryable();

        if (request.CategoryId.HasValue)
        {
            query = query.Where(s => s.ProductCategoryId == request.CategoryId.Value);
        }

        var subcategories = await query
            .Select(s => new ProductSubcategoryDto(
                s.Id,
                s.SubcategoryName,
                s.ProductCategoryId,
                s.Category.CategoryName,
                s.Products.Count
            ))
            .ToListAsync(cancellationToken);

        return new GetSubcategoriesResponse(true, null, subcategories);
    }
}
