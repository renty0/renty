using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetGapAnalysisActionPlanQuery : IRequest<List<GapActionPlanDto>>;

public class GetGapAnalysisActionPlanQueryHandler : IRequestHandler<GetGapAnalysisActionPlanQuery, List<GapActionPlanDto>>
{
    private readonly IApplicationDbContext _context;

    public GetGapAnalysisActionPlanQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<GapActionPlanDto>> Handle(GetGapAnalysisActionPlanQuery request, CancellationToken cancellationToken)
    {
        var categoryData = await _context.ProductCategories
            .Select(c => new
            {
                c.Id,
                CategoryName = c.NameEn,
                UniqueProducts = _context.Products.Count(p => p.Subcategory.ProductCategoryId == c.Id),
                TotalQuantitySold = _context.Sales
                    .Where(s => s.Product.Subcategory.ProductCategoryId == c.Id)
                    .Sum(s => s.OrderQuantity)
            })
            .ToListAsync(cancellationToken);

        return categoryData.Select(c =>
        {
            var gapScore = Math.Round(c.UniqueProducts > 0 ? (decimal)c.TotalQuantitySold / c.UniqueProducts : (decimal)c.TotalQuantitySold, 2);
            var gapLevel = gapScore < 1 ? "Low Gap" :
                           gapScore < 2 ? "Moderate Gap" :
                           gapScore < 5 ? "High Gap" : "Critical Gap";

            var operational = new List<string>();
            var strategic = new List<string>();
            var platform = new List<string>();
            var engagement = new List<string>();

            if (gapScore >= 5)
            {
                operational.Add($"Launch supply recruitment campaign for {c.CategoryName}");
                strategic.Add($"Allocate 15% more marketing budget to {c.CategoryName}");
                platform.Add($"Boost {c.CategoryName} SEO/Search ranking priority");
                engagement.Add($"Incentivize top lenders to list more {c.CategoryName} items");
            }
            else if (gapScore >= 50)
            {
                operational.Add($"Feature trending {c.CategoryName} items on homepage");
                strategic.Add($"Conduct competitor analysis for {c.CategoryName} segment");
                platform.Add($"Add 'High-Demand' badge to {c.CategoryName} listings");
                engagement.Add($"Send targeted push notifications to {c.CategoryName} renters");
            }
            else
            {
                operational.Add($"Monitor {c.CategoryName} demand for seasonal changes");
                strategic.Add($"Maintain current growth strategy for {c.CategoryName}");
                platform.Add($"Ensure price competitiveness for {c.CategoryName}");
                engagement.Add($"Ask users for reviews on {c.CategoryName} items");
            }

            return new GapActionPlanDto(
                c.Id,
                c.CategoryName,
                gapScore,
                gapLevel,
                operational,
                strategic,
                platform,
                engagement
            );
        })
        .OrderByDescending(x => x.GapScore)
        .ToList();
    }
}
