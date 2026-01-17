using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetCategoryGapAnalysisQuery : IRequest<List<CategoryGapAnalysisDto>>;

public class GetCategoryGapAnalysisQueryHandler : IRequestHandler<GetCategoryGapAnalysisQuery, List<CategoryGapAnalysisDto>>
{
    private readonly IApplicationDbContext _context;

    public GetCategoryGapAnalysisQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<CategoryGapAnalysisDto>> Handle(GetCategoryGapAnalysisQuery request, CancellationToken cancellationToken)
    {
        var categoryData = await _context.ProductCategories
            .Select(c => new
            {
                c.Id,
                c.CategoryName,
                UniqueProducts = _context.Products.Count(p => p.Subcategory.ProductCategoryId == c.Id),
                Sales = _context.Sales
                    .Where(s => s.Product.Subcategory.ProductCategoryId == c.Id)
                    .Select(s => new { s.OrderNumber, s.OrderQuantity, s.CustomerId })
                    .ToList()
            })
            .ToListAsync(cancellationToken);

        return categoryData.Select(c =>
        {
            var uniqueOrders = c.Sales.Select(s => s.OrderNumber).Distinct().Count();
            var totalQuantitySold = c.Sales.Sum(s => s.OrderQuantity);
            var uniqueCustomers = c.Sales.Select(s => s.CustomerId).Distinct().Count();
            
            var gapScore = Math.Round((decimal)(totalQuantitySold + 1) / (c.UniqueProducts + 1), 2);
            var gapLevel = gapScore < 50 ? "Low Gap" :
                           gapScore < 100 ? "Moderate Gap" :
                           gapScore < 200 ? "High Gap" : "Critical Gap";

            return new CategoryGapAnalysisDto(
                c.Id,
                c.CategoryName,
                c.UniqueProducts,
                uniqueOrders,
                totalQuantitySold,
                uniqueCustomers,
                gapScore,
                gapLevel
            );
        })
        .OrderByDescending(c => c.GapScore)
        .ToList();
    }
}
