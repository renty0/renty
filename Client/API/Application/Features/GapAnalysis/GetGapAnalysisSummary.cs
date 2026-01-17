using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetGapAnalysisSummaryQuery : IRequest<GapAnalysisSummaryDto>;

public class GetGapAnalysisSummaryQueryHandler : IRequestHandler<GetGapAnalysisSummaryQuery, GapAnalysisSummaryDto>
{
    private readonly IApplicationDbContext _context;

    public GetGapAnalysisSummaryQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GapAnalysisSummaryDto> Handle(GetGapAnalysisSummaryQuery request, CancellationToken cancellationToken)
    {
        var categoryData = await _context.ProductCategories
            .Select(c => new
            {
                c.CategoryName,
                UniqueProducts = _context.Products.Count(p => p.Subcategory.ProductCategoryId == c.Id),
                TotalQuantitySold = _context.Sales
                    .Where(s => s.Product.Subcategory.ProductCategoryId == c.Id)
                    .Sum(s => s.OrderQuantity)
            })
            .ToListAsync(cancellationToken);

        var totalCategories = categoryData.Count;
        if (totalCategories == 0) return new GapAnalysisSummaryDto(0, 0, 0, 0, "", 0, 0, 0, new List<CategoryGapScoreDto>());

        var gapData = categoryData.Select(c => new
        {
            c.CategoryName,
            c.UniqueProducts,
            c.TotalQuantitySold,
            GapScore = Math.Round(c.UniqueProducts > 0 ? (decimal)c.TotalQuantitySold / c.UniqueProducts : (decimal)c.TotalQuantitySold, 2)
        }).ToList();

        var criticalGaps = gapData.Where(g => g.GapScore >= 5).ToList();
        var mostSevere = gapData.OrderByDescending(g => g.GapScore).FirstOrDefault();

        var categoryGapsList = gapData.Select(g => new CategoryGapScoreDto(
            g.CategoryName, 
            g.GapScore, 
            g.GapScore < 1 ? "Low" : g.GapScore < 2 ? "Moderate" : g.GapScore < 5 ? "High" : "Critical",
            g.UniqueProducts,
            g.TotalQuantitySold
        )).ToList();

        return new GapAnalysisSummaryDto(
            totalCategories,
            criticalGaps.Count,
            totalCategories > 0 ? Math.Round((decimal)criticalGaps.Count / totalCategories * 100, 2) : 0,
            Math.Round(gapData.Average(g => g.GapScore), 2),
            mostSevere?.CategoryName ?? "",
            mostSevere?.GapScore ?? 0,
            categoryData.Sum(c => c.UniqueProducts),
            categoryData.Sum(c => c.TotalQuantitySold),
            categoryGapsList
        );
    }
}
