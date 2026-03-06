using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetDeadStockAnalysisQuery : IRequest<List<DeadStockDto>>;

public class GetDeadStockAnalysisQueryHandler : IRequestHandler<GetDeadStockAnalysisQuery, List<DeadStockDto>>
{
    private readonly IApplicationDbContext _context;

    public GetDeadStockAnalysisQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<DeadStockDto>> Handle(GetDeadStockAnalysisQuery request, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var thresholdDate = DateOnly.FromDateTime(now.AddDays(-90)); // 90 days of inactivity

        var deadStock = await _context.Products
            .Select(p => new
            {
                p.Id,
                ProductName = p.NameEn,
                CategoryName = p.Subcategory.Category.NameEn,
                p.ProductPrice,
                LastSaleDate = _context.Sales
                    .Where(s => s.ProductId == p.Id)
                    .OrderByDescending(s => s.OrderDate)
                    .Select(s => s.OrderDate)
                    .FirstOrDefault()
            })
            .Where(x => x.LastSaleDate == default || x.LastSaleDate < thresholdDate)
            .Take(20)
            .ToListAsync(cancellationToken);

        return deadStock.Select(x => new DeadStockDto(
            (int)x.Id,
            x.ProductName,
            x.CategoryName,
            1, // Assuming per product tracking
            x.ProductPrice,
            x.LastSaleDate == default ? 999 : DateOnly.FromDateTime(now).DayNumber - x.LastSaleDate.DayNumber,
            "Consider a discount campaign or bundling this item with high-demand products."
        ))
        .OrderByDescending(x => x.DaysSinceLastSale)
        .ToList();
    }
}
