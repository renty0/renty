using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetSubcategoryGapAnalysisQuery : IRequest<List<SubcategoryGapAnalysisDto>>;

public class GetSubcategoryGapAnalysisQueryHandler : IRequestHandler<GetSubcategoryGapAnalysisQuery, List<SubcategoryGapAnalysisDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSubcategoryGapAnalysisQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<SubcategoryGapAnalysisDto>> Handle(GetSubcategoryGapAnalysisQuery request, CancellationToken cancellationToken)
    {
        var subcategoryData = await _context.ProductSubcategories
            .Select(s => new
            {
                s.Id,
                SubcategoryName = s.NameEn,
                CategoryName = s.Category.NameEn,
                UniqueProducts = _context.Products.Count(p => p.ProductSubcategoryId == s.Id),
                Sales = _context.Sales
                    .Where(sale => sale.Product.ProductSubcategoryId == s.Id)
                    .Select(sale => new { sale.OrderNumber, sale.OrderQuantity, sale.CustomerId })
                    .ToList()
            })
            .ToListAsync(cancellationToken);

        return subcategoryData.Select(s =>
        {
            var uniqueOrders = s.Sales.Select(sale => sale.OrderNumber).Distinct().Count();
            var totalQuantitySold = s.Sales.Sum(sale => sale.OrderQuantity);
            var uniqueCustomers = s.Sales.Select(sale => sale.CustomerId).Distinct().Count();
            
            var gapScore = Math.Round((decimal)(totalQuantitySold + 1) / (s.UniqueProducts + 1), 2);
            var gapLevel = gapScore < 50 ? "Low Gap" :
                           gapScore < 100 ? "Moderate Gap" :
                           gapScore < 200 ? "High Gap" : "Critical Gap";

            return new SubcategoryGapAnalysisDto(
                s.Id,
                s.SubcategoryName,
                s.CategoryName,
                s.UniqueProducts,
                uniqueOrders,
                totalQuantitySold,
                uniqueCustomers,
                gapScore,
                gapLevel
            );
        })
        .OrderByDescending(s => s.GapScore)
        .ToList();
    }
}
