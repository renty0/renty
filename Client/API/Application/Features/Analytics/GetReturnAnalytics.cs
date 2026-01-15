using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Analytics;

public record GetReturnAnalyticsQuery() : IRequest<ReturnAnalyticsDto>;

public class GetReturnAnalyticsQueryHandler : IRequestHandler<GetReturnAnalyticsQuery, ReturnAnalyticsDto>
{
    private readonly IApplicationDbContext _context;

    public GetReturnAnalyticsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ReturnAnalyticsDto> Handle(GetReturnAnalyticsQuery request, CancellationToken cancellationToken)
    {
        var returns = await _context.Returns
            .Include(r => r.Product)
            .ToListAsync(cancellationToken);

        var totalReturns = returns.Sum(r => r.ReturnQuantity);
        var totalReturnValue = returns.Sum(r => r.ReturnValue);

        var totalSalesQuantity = await _context.Sales.SumAsync(s => s.OrderQuantity, cancellationToken);
        var returnRate = totalSalesQuantity > 0 ? (double)totalReturns / totalSalesQuantity * 100 : 0;

        var returnReasons = returns
            .GroupBy(r => r.ReturnReason ?? "Not Specified")
            .Select(g => new CategoryCountDto(g.Key, g.Count()))
            .OrderByDescending(g => g.Count)
            .ToList();

        return new ReturnAnalyticsDto(
            totalReturns,
            totalReturnValue,
            returnRate,
            returnReasons
        );
    }
}
