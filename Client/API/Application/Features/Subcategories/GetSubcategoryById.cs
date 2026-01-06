using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record GetSubcategoryByIdQuery(int Id) : IRequest<GetSubcategoryByIdResponse>;

public record GetSubcategoryByIdResponse(
    bool Success,
    string? Message,
    ProductSubcategoryDto? Subcategory
);

public class GetSubcategoryByIdQueryHandler : IRequestHandler<GetSubcategoryByIdQuery, GetSubcategoryByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSubcategoryByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetSubcategoryByIdResponse> Handle(GetSubcategoryByIdQuery request, CancellationToken cancellationToken)
    {
        var subcategory = await _context.ProductSubcategories
            .Include(s => s.Category)
            .Include(s => s.Products)
            .Where(s => s.Id == request.Id)
            .Select(s => new ProductSubcategoryDto(
                s.Id,
                s.SubcategoryName,
                s.ProductCategoryId,
                s.Category.CategoryName,
                s.Products.Count
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (subcategory == null)
        {
            return new GetSubcategoryByIdResponse(false, "Subcategory not found.", null);
        }

        return new GetSubcategoryByIdResponse(true, null, subcategory);
    }
}
