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
    decimal? MinPrice = null,
    decimal? MaxPrice = null,
    string? Color = null
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
                p.ProductName.ToLower().Contains(searchTerm) ||
                p.ProductSku.ToLower().Contains(searchTerm) ||
                (p.ProductDescription != null && p.ProductDescription.ToLower().Contains(searchTerm))
            );
        }

        if (request.MinPrice.HasValue)
        {
            query = query.Where(p => p.ProductPrice >= request.MinPrice.Value);
        }

        if (request.MaxPrice.HasValue)
        {
            query = query.Where(p => p.ProductPrice <= request.MaxPrice.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Color))
        {
            query = query.Where(p => p.ProductColor == request.Color);
        }

        var projectedQuery = query
            .OrderByDescending(p => p.Created)
            .Select(p => new ProductListDto(
                p.Id,
                p.ProductSku,
                p.ProductName,
                p.ProductPrice,
                p.DiscountPrice,
                p.ProductColor,
                p.Subcategory.SubcategoryName,
                p.Subcategory.Category.CategoryName
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
