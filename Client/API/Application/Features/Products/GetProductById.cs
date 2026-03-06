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
                p.NameAr,
                p.NameEn,
                p.ModelName,
                p.DescAr,
                p.DescEn,
                p.ProductColor,
                p.ProductStyle,
                p.ProductCost,
                p.ProductPrice,
                p.SkuType,
                p.DiscountPrice,
                p.DiscountPrice ?? p.ProductPrice,
                p.ProductPrice > 0 ? (p.ProductPrice - p.ProductCost) / p.ProductPrice * 100 : 0,
                p.ProductSubcategoryId,
                p.Subcategory.NameEn,
                p.Subcategory.Category.NameEn,
                p.Created,
                p.LastModified,
                p.Images.Select(i => new ProductImageDto(i.Id, i.Image != null ? i.Image.StoragePath : "", i.IsPrimary, i.DisplayOrder)).ToList()
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (product == null)
        {
            return new GetProductByIdResponse(false, "Product not found.", null);
        }

        return new GetProductByIdResponse(true, null, product);
    }
}
