using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record GetCategoriesQuery : IRequest<GetCategoriesResponse>;

public record GetCategoriesResponse(
    bool Success,
    string? Message,
    List<ProductCategoryDto> Categories
);

public class GetCategoriesQueryHandler : IRequestHandler<GetCategoriesQuery, GetCategoriesResponse>
{
    private readonly IApplicationDbContext _context;

    public GetCategoriesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetCategoriesResponse> Handle(GetCategoriesQuery request, CancellationToken cancellationToken)
    {
        var categories = await _context.ProductCategories
            .Include(c => c.Subcategories)
            .Select(c => new ProductCategoryDto(
                c.Id,
                c.CategoryName,
                c.Subcategories.Count
            ))
            .ToListAsync(cancellationToken);

        return new GetCategoriesResponse(true, null, categories);
    }
}
