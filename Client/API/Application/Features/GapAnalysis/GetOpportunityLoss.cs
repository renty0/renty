using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetOpportunityLossQuery : IRequest<List<OpportunityLossDto>>;

public class GetOpportunityLossQueryHandler : IRequestHandler<GetOpportunityLossQuery, List<OpportunityLossDto>>
{
    private readonly IApplicationDbContext _context;

    public GetOpportunityLossQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<OpportunityLossDto>> Handle(GetOpportunityLossQuery request, CancellationToken cancellationToken)
    {
        var categoryData = await _context.ProductCategories
            .Select(c => new
            {
                c.Id,
                CategoryName = c.NameEn,
                Supply = _context.Products.Count(p => p.Subcategory.ProductCategoryId == c.Id),
                Demand = _context.Sales.Where(s => s.Product.Subcategory.ProductCategoryId == c.Id).Sum(s => s.OrderQuantity),
                AvgPrice = _context.Products.Where(p => p.Subcategory.ProductCategoryId == c.Id).Average(p => (decimal?)p.RentPricePerDay) ?? 0
            })
            .ToListAsync(cancellationToken);

        return categoryData
            .Where(c => c.Demand > c.Supply)
            .Select(c =>
            {
                var gap = c.Demand - c.Supply;
                var estimatedLoss = gap * c.AvgPrice;
                return new OpportunityLossDto(
                    c.Id,
                    c.CategoryName,
                    gap,
                    Math.Round(c.AvgPrice, 2),
                    Math.Round(estimatedLoss, 2),
                    $"Inventory expansion of at least {gap} units recommended to capture lost revenue."
                );
            })
            .OrderByDescending(x => x.EstimatedOpportunityLoss)
            .ToList();
    }
}
