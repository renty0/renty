using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record GetTopProductsQuery(
    int Top = 10,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? TerritoryId = null
) : IRequest<GetTopProductsResponse>;

public record GetTopProductsResponse(
    bool Success,
    string? Message,
    List<TopProductDto> Products
);

public class GetTopProductsQueryHandler : IRequestHandler<GetTopProductsQuery, GetTopProductsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetTopProductsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetTopProductsResponse> Handle(GetTopProductsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Sales
            .Include(s => s.Product)
            .AsQueryable();

        if (request.StartDate.HasValue)
        {
            query = query.Where(s => s.OrderDate >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            query = query.Where(s => s.OrderDate <= request.EndDate.Value);
        }

        if (request.TerritoryId.HasValue)
        {
            query = query.Where(s => s.TerritoryId == request.TerritoryId.Value);
        }

        var products = await query
            .GroupBy(s => new { s.ProductId, ProductName = s.Product.NameEn })
            .Select(g => new TopProductDto(
                g.Key.ProductId,
                g.Key.ProductName,
                g.Sum(s => s.OrderQuantity),
                g.Sum(s => s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice))
            ))
            .OrderByDescending(p => p.Revenue)
            .Take(request.Top)
            .ToListAsync(cancellationToken);

        return new GetTopProductsResponse(true, null, products);
    }
}
