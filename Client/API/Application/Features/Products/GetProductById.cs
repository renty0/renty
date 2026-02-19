using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record GetProductByIdQuery(long Id) : IRequest<GetProductByIdResponse>;

public record GetProductByIdResponse(
    bool Success,
    string? Message,
    ProductDto? Product
);

public class GetProductByIdQueryHandler : IRequestHandler<GetProductByIdQuery, GetProductByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetProductByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetProductByIdResponse> Handle(GetProductByIdQuery request, CancellationToken cancellationToken)
    {
        var product = await _context.Products
            .Include(p => p.Subcategory)
            .ThenInclude(s => s.Category)
            .Where(p => p.Id == request.Id)
            .Select(p => new ProductDto(
                p.Id,
                p.ProductSku,
                p.NameEn,
                p.NameAr,
                p.ModelName,
                p.DescriptionEn,
                p.DescriptionAr,
                p.Color,
                p.Style,
                p.ProductCost,
                p.RentPricePerDay,
                p.SkuType,
                p.RentDiscountPrice,
                p.EffectivePrice,
                p.ProfitMargin,
                p.ProductSubcategoryId,
                p.Subcategory.NameEn,
                p.Subcategory.NameAr,
                p.Subcategory.Category.NameEn,
                p.Subcategory.Category.NameAr,
                p.BrandId,
                p.Brand != null ? p.Brand.NameEn : null,
                p.Brand != null ? p.Brand.NameAr : null,
                p.Created,
                p.LastModified,
                p.Images.Select(i => new ProductImageDto(i.Id, i.ImageUrl, i.IsPrimary, i.DisplayOrder)).ToList()
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (product == null)
        {
            return new GetProductByIdResponse(false, "Product not found.", null);
        }

        return new GetProductByIdResponse(true, null, product);
    }
}
