using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetGeographicGapHeatmapQuery : IRequest<List<GeographicHeatmapDto>>;

public class GetGeographicGapHeatmapQueryHandler : IRequestHandler<GetGeographicGapHeatmapQuery, List<GeographicHeatmapDto>>
{
    private readonly IApplicationDbContext _context;

    public GetGeographicGapHeatmapQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<GeographicHeatmapDto>> Handle(GetGeographicGapHeatmapQuery request, CancellationToken cancellationToken)
    {
        var territories = await _context.Territories.ToListAsync(cancellationToken);
        var categories = await _context.ProductCategories.ToListAsync(cancellationToken);

        var heatmap = new List<GeographicHeatmapDto>();

        foreach (var territory in territories)
        {
            var categoryGaps = new List<CategoryGapScoreDto>();

            foreach (var category in categories)
            {
                var supply = await _context.Products.CountAsync(p => p.Subcategory.ProductCategoryId == category.Id, cancellationToken);
                var demand = await _context.Sales
                    .Where(s => s.TerritoryId == territory.Id && s.Product.Subcategory.ProductCategoryId == category.Id)
                    .SumAsync(s => s.OrderQuantity, cancellationToken);

                var score = Math.Round((decimal)(demand + 1) / (supply + 1), 2);
                var level = score < 50 ? "Low" : score < 100 ? "Moderate" : score < 200 ? "High" : "Critical";

                categoryGaps.Add(new CategoryGapScoreDto(category.CategoryName, score, level, supply, demand));
            }

            heatmap.Add(new GeographicHeatmapDto(
                $"{territory.Region} - {territory.Country}",
                categoryGaps
            ));
        }

        return heatmap;
    }
}
