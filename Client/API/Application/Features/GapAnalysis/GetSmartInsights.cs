using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetSmartInsightsQuery : IRequest<List<SmartInsightDto>>;

public class GetSmartInsightsQueryHandler : IRequestHandler<GetSmartInsightsQuery, List<SmartInsightDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSmartInsightsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<SmartInsightDto>> Handle(GetSmartInsightsQuery request, CancellationToken cancellationToken)
    {
        var insights = new List<SmartInsightDto>();

        // 1. GAP Insight
        var categories = await _context.ProductCategories
            .Select(c => new
            {
                CategoryName = c.NameEn,
                Supply = _context.Products.Count(p => p.Subcategory.ProductCategoryId == c.Id),
                Demand = _context.Sales.Where(s => s.Product.Subcategory.ProductCategoryId == c.Id).Sum(s => s.OrderQuantity)
            })
            .ToListAsync(cancellationToken);

        var mostSevere = categories.Select(c => new { CategoryName = c.CategoryName, Score = c.Supply > 0 ? (decimal)c.Demand / c.Supply : (decimal)c.Demand })
            .OrderByDescending(x => x.Score).FirstOrDefault();

        if (mostSevere != null && mostSevere.Score >= 5)
        {
            insights.Add(new SmartInsightDto(
                "Critical Supply Shortage",
                $"Category '{mostSevere.CategoryName}' has a critical gap. Demand is significantly higher than current inventory.",
                "Danger"
            ));
        }

        // 2. REVENUE Insight
        var totalOppLoss = categories.Where(c => c.Demand > c.Supply)
            .Sum(c => (c.Demand - c.Supply) * (_context.Products.Where(p => p.Subcategory.ProductCategoryId == _context.ProductCategories.First(pc => pc.NameEn == c.CategoryName).Id).Average(p => (decimal?)p.ProductPrice) ?? 0m));

        if (totalOppLoss > 1000)
        {
            insights.Add(new SmartInsightDto(
                "Revenue Opportunity",
                $"You are losing approximately ${Math.Round(totalOppLoss, 2)} due to undersupplied categories. Expanding inventory could capture this revenue.",
                "Warning"
            ));
        }

        // 3. TREND Insight
        var now = DateTime.UtcNow;
        var prevMonthStart = new DateOnly(now.Year, now.Month, 1).AddMonths(-1);
        var curMonthStart = new DateOnly(now.Year, now.Month, 1);

        var curDemand = await _context.Sales.Where(s => s.OrderDate >= curMonthStart).SumAsync(s => (int?)s.OrderQuantity, cancellationToken) ?? 0;
        var prevDemand = await _context.Sales.Where(s => s.OrderDate >= prevMonthStart && s.OrderDate < curMonthStart).SumAsync(s => (int?)s.OrderQuantity, cancellationToken) ?? 0;

        if (curDemand > prevDemand && prevDemand > 0)
        {
            var growth = Math.Round((decimal)(curDemand - prevDemand) / prevDemand * 100, 1);
            insights.Add(new SmartInsightDto(
                "Growing Demand",
                $"Platform demand grew by {growth}% compared to last month. Ensure supply keeps up!",
                "Success"
            ));
        }

        return insights;
    }
}
