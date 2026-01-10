using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record GetCategoryByIdQuery(int Id) : IRequest<ProductCategoryDto?>;

public class GetCategoryByIdQueryHandler : IRequestHandler<GetCategoryByIdQuery, ProductCategoryDto?>
{
    private readonly IApplicationDbContext _context;

    public GetCategoryByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ProductCategoryDto?> Handle(GetCategoryByIdQuery request, CancellationToken cancellationToken)
    {
        return await _context.ProductCategories
            .AsNoTracking()
            .Include(c => c.Subcategories)
            .Where(c => c.Id == request.Id)
            .Select(c => new ProductCategoryDto(
                c.Id,
                c.CategoryName,
                c.Description,
                c.LogoId,
                c.Logo != null ? c.Logo.StoragePath : null,
                c.Subcategories.Count
            ))
            .FirstOrDefaultAsync(cancellationToken);
    }
}
