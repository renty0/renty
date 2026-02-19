using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetGapAnalysisTrendsQuery : IRequest<List<GapTrendDto>>;

public class GetGapAnalysisTrendsQueryHandler : IRequestHandler<GetGapAnalysisTrendsQuery, List<GapTrendDto>>
{
    private readonly IApplicationDbContext _context;

    public GetGapAnalysisTrendsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<GapTrendDto>> Handle(GetGapAnalysisTrendsQuery request, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var currentMonthStart = new DateOnly(now.Year, now.Month, 1);
        var prevMonthStart = currentMonthStart.AddMonths(-1);

        var categoryList = await _context.ProductCategories
            .Select(c => new { c.Id, CategoryName = c.NameEn })
            .ToListAsync(cancellationToken);

        var trends = new List<GapTrendDto>();

        foreach (var category in categoryList)
        {
            // Current Month
            var currSupply = await _context.Products.CountAsync(p => p.Subcategory.ProductCategoryId == category.Id, cancellationToken);
            var currDemand = await _context.Sales
                .Where(s => s.Product.Subcategory.ProductCategoryId == category.Id && s.OrderDate >= currentMonthStart)
                .SumAsync(s => s.OrderQuantity, cancellationToken);
            var currScore = Math.Round((decimal)(currDemand + 1) / (currSupply + 1), 2);

            // Previous Month
            var prevDemand = await _context.Sales
                .Where(s => s.Product.Subcategory.ProductCategoryId == category.Id && s.OrderDate >= prevMonthStart && s.OrderDate < currentMonthStart)
                .SumAsync(s => s.OrderQuantity, cancellationToken);
            var prevScore = Math.Round((decimal)(prevDemand + 1) / (currSupply + 1), 2); // Assuming supply is relatively stable or using current supply

            var changePct = prevScore > 0 ? Math.Round((currScore - prevScore) / prevScore * 100, 2) : 0;
            
            var status = changePct > 10 ? "Worsening" : changePct < -10 ? "Improving" : "Stable";

            trends.Add(new GapTrendDto(
                category.Id,
                category.CategoryName,
                prevScore,
                currScore,
                changePct,
                status
            ));
        }

        return trends.OrderByDescending(t => Math.Abs(t.GapChangePercentage)).ToList();
    }
}
