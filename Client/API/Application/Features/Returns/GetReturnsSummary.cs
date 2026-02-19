using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Returns;

public record GetReturnsSummaryQuery(
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? TerritoryId = null
) : IRequest<GetReturnsSummaryResponse>;

public record GetReturnsSummaryResponse(
    bool Success,
    string? Message,
    ReturnsSummaryDto? Summary
);

public class GetReturnsSummaryQueryHandler : IRequestHandler<GetReturnsSummaryQuery, GetReturnsSummaryResponse>
{
    private readonly IApplicationDbContext _context;

    public GetReturnsSummaryQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetReturnsSummaryResponse> Handle(GetReturnsSummaryQuery request, CancellationToken cancellationToken)
    {
        var returnsQuery = _context.Returns
            .Include(r => r.Product)
            .AsQueryable();

        var salesQuery = _context.Sales.AsQueryable();

        if (request.StartDate.HasValue)
        {
            returnsQuery = returnsQuery.Where(r => r.ReturnDate >= request.StartDate.Value);
            salesQuery = salesQuery.Where(s => s.OrderDate >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            returnsQuery = returnsQuery.Where(r => r.ReturnDate <= request.EndDate.Value);
            salesQuery = salesQuery.Where(s => s.OrderDate <= request.EndDate.Value);
        }

        if (request.TerritoryId.HasValue)
        {
            returnsQuery = returnsQuery.Where(r => r.TerritoryId == request.TerritoryId.Value);
            salesQuery = salesQuery.Where(s => s.TerritoryId == request.TerritoryId.Value);
        }

        var totalSalesQuantity = await salesQuery.SumAsync(s => s.OrderQuantity, cancellationToken);

        var returnsSummary = await returnsQuery
            .GroupBy(r => 1)
            .Select(g => new
            {
                TotalReturns = g.Count(),
                TotalQuantity = g.Sum(r => r.ReturnQuantity),
                TotalValue = g.Sum(r => r.ReturnQuantity * (r.Product.RentDiscountPrice ?? r.Product.RentPricePerDay))
            })
            .FirstOrDefaultAsync(cancellationToken);

        var summary = new ReturnsSummaryDto(
            returnsSummary?.TotalReturns ?? 0,
            returnsSummary?.TotalQuantity ?? 0,
            returnsSummary?.TotalValue ?? 0,
            totalSalesQuantity > 0
                ? (decimal)(returnsSummary?.TotalQuantity ?? 0) / totalSalesQuantity * 100
                : 0
        );

        return new GetReturnsSummaryResponse(true, null, summary);
    }
}
