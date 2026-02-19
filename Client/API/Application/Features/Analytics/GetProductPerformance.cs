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
        // 1. Top Products (Calculated in DB)
        var topProducts = await _context.Sales
            .Select(s => new
            {
                s.ProductId,
                ProductName = s.Product != null ? s.Product.NameEn : "Unknown",
                // Calculate line total in DB: Quantity * EffectivePrice
                LineRevenue = s.OrderQuantity * (s.Product != null ? (s.Product.RentDiscountPrice ?? s.Product.RentPricePerDay) : 0),
                s.OrderQuantity
            })
            .GroupBy(x => new { x.ProductId, x.ProductName })
            .Select(g => new
            {
                g.Key.ProductName,
                TotalRevenue = g.Sum(x => x.LineRevenue),
                TotalQuantity = g.Sum(x => x.OrderQuantity)
            })
            .OrderByDescending(x => x.TotalRevenue)
            .Take(request.Top)
            .ToListAsync(cancellationToken);

        // 2. Category Performance (Calculated in DB)
        var categoryStats = await _context.Sales
            .Select(s => new
            {
                CategoryName = s.Product != null && s.Product.Subcategory != null && s.Product.Subcategory.Category != null
                    ? s.Product.Subcategory.Category.NameEn
                    : "Unknown",
                LineRevenue = s.OrderQuantity * (s.Product != null ? (s.Product.RentDiscountPrice ?? s.Product.RentPricePerDay) : 0),
                s.OrderQuantity
            })
            .GroupBy(x => x.CategoryName)
            .Select(g => new
            {
                CategoryName = g.Key,
                Revenue = g.Sum(x => x.LineRevenue),
                Quantity = g.Sum(x => x.OrderQuantity)
            })
            .OrderByDescending(x => x.Revenue)
            .ToListAsync(cancellationToken);

        var categoryPerformance = categoryStats
            .Select(c => new CategoryPerformanceDto(c.CategoryName, c.Revenue, c.Quantity))
            .ToList();

        return new ProductPerformanceDto(
            topProducts.Select(p => new CategoryCountDto(p.ProductName, (int)p.TotalQuantity)).ToList(),
            categoryPerformance
        );
    }
}
