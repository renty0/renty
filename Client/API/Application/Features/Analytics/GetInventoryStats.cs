using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Analytics;

public record GetInventoryStatsQuery(int Top = 5) : IRequest<InventoryStatsDto>;

public class GetInventoryStatsQueryHandler : IRequestHandler<GetInventoryStatsQuery, InventoryStatsDto>
{
    private readonly IApplicationDbContext _context;

    public GetInventoryStatsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<InventoryStatsDto> Handle(GetInventoryStatsQuery request, CancellationToken cancellationToken)
    {
        var totalProducts = await _context.Products.CountAsync(cancellationToken);
        var totalStock = await _context.Sales.SumAsync(s => s.OrderQuantity, cancellationToken);

        var topProducts = await _context.Sales
            .GroupBy(s => new { s.ProductId, ProductName = s.Product!.NameEn })
            .Select(g => new
            {
                ProductName = g.Key.ProductName,
                TotalQuantity = g.Sum(s => s.OrderQuantity)
            })
            .OrderByDescending(p => p.TotalQuantity)
            .Take(request.Top)
            .ToListAsync(cancellationToken);

        var salesWithCategories = await _context.Sales
            .Include(s => s.Product)
                .ThenInclude(p => p.Subcategory)
                    .ThenInclude(sc => sc.Category)
            .ToListAsync(cancellationToken);

        var revenueByCategory = salesWithCategories
            .GroupBy(s => s.Product?.Subcategory?.Category?.NameEn ?? "Unknown")
            .Select(g => new CategoryPerformanceDto(
                g.Key,
                g.Sum(s => s.LineTotal),
                g.Sum(s => s.OrderQuantity)
            ))
            .OrderByDescending(c => c.Revenue)
            .ToList();

        return new InventoryStatsDto(
            totalProducts,
            (int)totalStock,
            topProducts.Select(p => new CategoryCountDto(p.ProductName ?? "Unknown", (int)p.TotalQuantity)).ToList(),
            revenueByCategory
        );
    }
}
