using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Features.Analytics;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetGlobalKPIsQuery : IRequest<GlobalKPIsDto>;

public class GetGlobalKPIsQueryHandler : IRequestHandler<GetGlobalKPIsQuery, GlobalKPIsDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ISender _sender;

    public GetGlobalKPIsQueryHandler(IApplicationDbContext context, ISender sender)
    {
        _context = context;
        _sender = sender;
    }

    public async Task<GlobalKPIsDto> Handle(GetGlobalKPIsQuery request, CancellationToken cancellationToken)
    {
        // 1. Basic Stats
        var totalRevenue = await _context.Sales
            .SumAsync(x => x.OrderQuantity * (x.Product.DiscountPrice ?? x.Product.ProductPrice), cancellationToken);

        var totalOrders = await _context.Sales.CountAsync(cancellationToken);
        var totalCustomers = await _context.Customers.CountAsync(cancellationToken);
        var totalProducts = await _context.Products.CountAsync(cancellationToken);

        // 2. Gap Stats
        var categories = await _context.ProductCategories
            .Select(c => new
            {
                c.NameEn,
                Supply = _context.Products.Count(p => p.Subcategory.ProductCategoryId == c.Id),
                Demand = _context.Sales.Where(s => s.Product.Subcategory.ProductCategoryId == c.Id).Sum(s => s.OrderQuantity),
                AvgPrice = _context.Products.Where(p => p.Subcategory.ProductCategoryId == c.Id).Average(p => (decimal?)p.ProductPrice) ?? 0
            })
            .ToListAsync(cancellationToken);

        var gapScores = categories.Select(c =>
        {
            var score = c.Supply > 0 ? (decimal)c.Demand / c.Supply : (decimal)c.Demand;
            var oppLoss = c.Demand > c.Supply ? (c.Demand - c.Supply) * c.AvgPrice : 0m;
            return new
            {
                c.NameEn,
                Score = score,
                Level = score < 1 ? "Low" : score < 2 ? "Moderate" : score < 5 ? "High" : "Critical",
                OppLoss = oppLoss
            };
        }).ToList();

        var avgGapScore = gapScores.Any() ? gapScores.Average(x => x.Score) : 0;
        var criticalGaps = gapScores.Count(x => x.Score >= 5);
        var totalOppLoss = gapScores.Sum(x => x.OppLoss);

        var gapLevelDistribution = gapScores
            .GroupBy(x => x.Level)
            .Select(g => new GapLevelCountDto(g.Key, g.Count()))
            .ToList();

        var latestSale = await _context.Sales.OrderByDescending(s => s.OrderDate).FirstOrDefaultAsync(cancellationToken);
        var baseDate = latestSale != null ? new DateTime(latestSale.OrderDate.Year, latestSale.OrderDate.Month, 1) : DateTime.UtcNow;
        
        var revenueTrend = new List<KpiRevenueTrendDto>();
        for (int i = 5; i >= 0; i--)
        {
            var targetMonth = baseDate.AddMonths(-i);
            
            var monthlyRevenue = await _context.Sales
                .Where(x => x.OrderDate.Year == targetMonth.Year && x.OrderDate.Month == targetMonth.Month)
                .SumAsync(x => x.OrderQuantity * (x.Product.DiscountPrice ?? x.Product.ProductPrice), cancellationToken);
                
            revenueTrend.Add(new KpiRevenueTrendDto(targetMonth.ToString("MMM yyyy"), monthlyRevenue));
        }

        var insights = await _sender.Send(new GetSmartInsightsQuery(), cancellationToken);

        return new GlobalKPIsDto(
            totalRevenue,
            totalOrders,
            totalCustomers,
            totalProducts,
            Math.Round(avgGapScore, 2),
            criticalGaps,
            Math.Round(totalOppLoss, 2),
            revenueTrend,
            new List<CategoryGapAnalysisDto>(), // Simplified for metrics
            gapLevelDistribution,
            insights
        );
    }
}
