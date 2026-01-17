using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetTerritoryGapAnalysisQuery : IRequest<List<TerritoryGapAnalysisDto>>;

public class GetTerritoryGapAnalysisQueryHandler : IRequestHandler<GetTerritoryGapAnalysisQuery, List<TerritoryGapAnalysisDto>>
{
    private readonly IApplicationDbContext _context;

    public GetTerritoryGapAnalysisQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<TerritoryGapAnalysisDto>> Handle(GetTerritoryGapAnalysisQuery request, CancellationToken cancellationToken)
    {
        var territoryData = await _context.Sales
            .Include(s => s.Territory)
            .Include(s => s.Product)
            .ThenInclude(p => p.Subcategory)
            .ThenInclude(sc => sc.Category)
            .GroupBy(s => new 
            { 
                s.TerritoryId, 
                s.Territory.Region, 
                s.Territory.Country, 
                CategoryId = s.Product.Subcategory.ProductCategoryId,
                CategoryName = s.Product.Subcategory.Category.CategoryName 
            })
            .Select(g => new
            {
                g.Key.TerritoryId,
                g.Key.Region,
                g.Key.Country,
                g.Key.CategoryId,
                g.Key.CategoryName,
                UniqueOrders = g.Select(s => s.OrderNumber).Distinct().Count(),
                TotalQuantitySold = g.Sum(s => s.OrderQuantity),
                UniqueCustomers = g.Select(s => s.CustomerId).Distinct().Count(),
                UniqueProducts = _context.Products.Count(p => p.Subcategory.ProductCategoryId == g.Key.CategoryId)
            })
            .Select(x => new TerritoryGapAnalysisDto(
                x.TerritoryId,
                x.Region,
                x.Country,
                x.CategoryId,
                x.CategoryName,
                x.UniqueOrders,
                x.TotalQuantitySold,
                x.UniqueCustomers,
                x.UniqueProducts > 0 ? (decimal)x.TotalQuantitySold / x.UniqueProducts : (decimal)x.TotalQuantitySold
            ))
            .ToListAsync(cancellationToken);

        return territoryData
            .OrderBy(t => t.Region)
            .ThenBy(t => t.Country)
            .ThenByDescending(t => t.TotalQuantitySold)
            .ToList();
    }
}
