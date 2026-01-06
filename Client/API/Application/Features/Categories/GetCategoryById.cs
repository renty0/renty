using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record GetCategoryByIdQuery(int Id) : IRequest<GetCategoryByIdResponse>;

public record GetCategoryByIdResponse(
    bool Success,
    string? Message,
    ProductCategoryDto? Category
);

public class GetCategoryByIdQueryHandler : IRequestHandler<GetCategoryByIdQuery, GetCategoryByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetCategoryByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetCategoryByIdResponse> Handle(GetCategoryByIdQuery request, CancellationToken cancellationToken)
    {
        var category = await _context.ProductCategories
            .Include(c => c.Subcategories)
            .Where(c => c.Id == request.Id)
            .Select(c => new ProductCategoryDto(
                c.Id,
                c.CategoryName,
                c.Subcategories.Count
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (category == null)
        {
            return new GetCategoryByIdResponse(false, "Category not found.", null);
        }

        return new GetCategoryByIdResponse(true, null, category);
    }
}
