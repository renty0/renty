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
        if (totalCategories == 0) return new GapAnalysisSummaryDto(0, 0, 0, 0, "", 0, 0, 0);

        var gapData = categoryData.Select(c => new
        {
            c.CategoryName,
            c.UniqueProducts,
            c.TotalQuantitySold,
            GapScore = Math.Round((decimal)(c.TotalQuantitySold + 1) / (c.UniqueProducts + 1), 2)
        }).ToList();

        var criticalGaps = gapData.Where(g => g.GapScore >= 200).ToList();
        var mostSevere = gapData.OrderByDescending(g => g.GapScore).FirstOrDefault();

        return new GapAnalysisSummaryDto(
            totalCategories,
            criticalGaps.Count,
            totalCategories > 0 ? Math.Round((decimal)criticalGaps.Count / totalCategories * 100, 2) : 0,
            Math.Round(gapData.Average(g => g.GapScore), 2),
            mostSevere?.CategoryName ?? "",
            mostSevere?.GapScore ?? 0,
            categoryData.Sum(c => c.UniqueProducts),
            categoryData.Sum(c => c.TotalQuantitySold)
        );
    }
}
