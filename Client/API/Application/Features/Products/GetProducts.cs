using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record GetProductsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    int? SubcategoryId = null,
    int? CategoryId = null,
    string? SearchTerm = null,
    decimal? minPrice = null,
    decimal? maxPrice = null,
    string? color = null,
    string? sortBy = null,
    string? sortOrder = null
) : IRequest<GetProductsResponse>;

public record GetProductsResponse(
    bool Success,
    string? Message,
    PaginatedList<ProductListDto> Products
);

public class GetProductsQueryHandler : IRequestHandler<GetProductsQuery, GetProductsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetProductsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetProductsResponse> Handle(GetProductsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Products
            .Include(p => p.Subcategory)
            .ThenInclude(s => s.Category)
            .AsQueryable();

        if (request.SubcategoryId.HasValue)
        {
            query = query.Where(p => p.ProductSubcategoryId == request.SubcategoryId.Value);
        }

        if (request.CategoryId.HasValue)
        {
            query = query.Where(p => p.Subcategory.ProductCategoryId == request.CategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var searchTerm = request.SearchTerm.ToLower();
            query = query.Where(p =>
                p.NameEn.ToLower().Contains(searchTerm) ||
                p.NameAr.ToLower().Contains(searchTerm) ||
                p.ProductSku.ToLower().Contains(searchTerm) ||
                p.DescEn.ToLower().Contains(searchTerm) ||
                p.DescAr.ToLower().Contains(searchTerm)
            );
        }

        if (request.minPrice.HasValue)
        {
            query = query.Where(p => p.ProductPrice >= request.minPrice.Value);
        }

        if (request.maxPrice.HasValue)
        {
            query = query.Where(p => p.ProductPrice <= request.maxPrice.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.color))
        {
            query = query.Where(p => p.ProductColor == request.color);
        }

        // Apply sorting
        if (!string.IsNullOrWhiteSpace(request.sortBy))
        {
            var isDescending = request.sortOrder?.ToLower() == "desc";
            query = request.sortBy.ToLower() switch
            {
                "name" => isDescending ? query.OrderByDescending(p => p.NameEn) : query.OrderBy(p => p.NameEn),
                "sku" => isDescending ? query.OrderByDescending(p => p.ProductSku) : query.OrderBy(p => p.ProductSku),
                "price" => isDescending ? query.OrderByDescending(p => p.ProductPrice) : query.OrderBy(p => p.ProductPrice),
                "date" => isDescending ? query.OrderByDescending(p => p.Created) : query.OrderBy(p => p.Created),
                _ => query.OrderByDescending(p => p.Created)
            };
        }
        else
        {
            query = query.OrderByDescending(p => p.Created);
        }

        var projectedQuery = query
            .Select(p => new ProductListDto(
                p.Id,
                p.ProductSku,
                p.NameAr,
                p.NameEn,
                p.ProductPrice,
                p.DiscountPrice,
                p.ProductColor,
                p.Subcategory.NameEn,
                p.Subcategory.Category.NameEn,
                p.Created,
                p.LastModified,
                p.Images.Where(i => i.IsPrimary).Select(i => i.Image.StoragePath).FirstOrDefault()
            ));

        var products = await PaginatedList<ProductListDto>.CreateAsync(
            projectedQuery,
            request.PageNumber,
            request.PageSize,
            cancellationToken
        );

        return new GetProductsResponse(true, null, products);
    }
}
