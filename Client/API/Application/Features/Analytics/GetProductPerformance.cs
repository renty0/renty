using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Analytics;

public record GetProductPerformanceQuery(int Top = 10) : IRequest<ProductPerformanceDto>;

public class GetProductPerformanceQueryHandler : IRequestHandler<GetProductPerformanceQuery, ProductPerformanceDto>
{
    private readonly IApplicationDbContext _context;

    public GetProductPerformanceQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ProductPerformanceDto> Handle(GetProductPerformanceQuery request, CancellationToken cancellationToken)
    {
        var topProducts = await _context.Sales
            .GroupBy(s => new { s.ProductId, s.Product!.ProductName })
            .Select(g => new
            {
                ProductName = g.Key.ProductName,
                TotalRevenue = g.Sum(s => s.LineTotal),
                TotalQuantity = g.Sum(s => s.OrderQuantity)
            })
            .OrderByDescending(p => p.TotalRevenue)
            .Take(request.Top)
            .ToListAsync(cancellationToken);

        // Get all sales with product and category info
        var salesWithCategories = await _context.Sales
            .Include(s => s.Product)
                .ThenInclude(p => p.Subcategory)
                    .ThenInclude(sc => sc.Category)
            .ToListAsync(cancellationToken);

        // Group by category in memory
        var categoryPerformance = salesWithCategories
            .GroupBy(s => s.Product?.Subcategory?.Category?.CategoryName ?? "Unknown")
            .Select(g => new CategoryPerformanceDto(
                g.Key,
                g.Sum(s => s.LineTotal),
                g.Sum(s => s.OrderQuantity)
            ))
            .OrderByDescending(c => c.Revenue)
            .ToList();

        return new ProductPerformanceDto(
            topProducts.Select(p => new CategoryCountDto(p.ProductName ?? "Unknown", (int)p.TotalQuantity)).ToList(),
            categoryPerformance
        );
    }
}
