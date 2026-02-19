using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record GetSalesSummaryQuery(
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? TerritoryId = null,
    int? CategoryId = null
) : IRequest<GetSalesSummaryResponse>;

public record GetSalesSummaryResponse(
    bool Success,
    string? Message,
    SalesSummaryDto? Summary
);

public class GetSalesSummaryQueryHandler : IRequestHandler<GetSalesSummaryQuery, GetSalesSummaryResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSalesSummaryQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetSalesSummaryResponse> Handle(GetSalesSummaryQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Sales
            .Include(s => s.Product)
            .ThenInclude(p => p.Subcategory)
            .AsQueryable();

        if (request.StartDate.HasValue)
        {
            query = query.Where(s => s.OrderDate >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            query = query.Where(s => s.OrderDate <= request.EndDate.Value);
        }

        if (request.TerritoryId.HasValue)
        {
            query = query.Where(s => s.TerritoryId == request.TerritoryId.Value);
        }

        if (request.CategoryId.HasValue)
        {
            query = query.Where(s => s.Product.Subcategory.ProductCategoryId == request.CategoryId.Value);
        }

        var summary = await query
            .GroupBy(s => 1)
            .Select(g => new SalesSummaryDto(
                g.Sum(s => s.OrderQuantity * (s.Product.RentDiscountPrice ?? s.Product.RentPricePerDay)),
                g.Select(s => s.OrderNumber).Distinct().Count(),
                g.Sum(s => s.OrderQuantity),
                g.Any() ? g.Sum(s => s.OrderQuantity * (s.Product.RentDiscountPrice ?? s.Product.RentPricePerDay)) / g.Select(s => s.OrderNumber).Distinct().Count() : 0
            ))
            .FirstOrDefaultAsync(cancellationToken);

        summary ??= new SalesSummaryDto(0, 0, 0, 0);

        return new GetSalesSummaryResponse(true, null, summary);
    }
}
