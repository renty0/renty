using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Analytics;

public record GetSalesTrendQuery(string Interval = "monthly") : IRequest<List<SalesTrendDto>>;

public class GetSalesTrendQueryHandler : IRequestHandler<GetSalesTrendQuery, List<SalesTrendDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSalesTrendQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<SalesTrendDto>> Handle(GetSalesTrendQuery request, CancellationToken cancellationToken)
    {
        var sales = await _context.Sales
            .Include(s => s.Product)
            .ToListAsync(cancellationToken);

        if (request.Interval.ToLower() == "daily")
        {
            return sales
                .GroupBy(s => s.OrderDate)
                .Select(g => new SalesTrendDto(
                    g.Key.ToString("yyyy-MM-dd"),
                    g.Count(),
                    g.Sum(s => s.LineTotal),
                    g.Sum(s => s.OrderQuantity)
                ))
                .OrderBy(s => s.Period)
                .ToList();
        }
        else 
        {
            return sales
                .GroupBy(s => new { s.OrderDate.Year, s.OrderDate.Month })
                .Select(g => new SalesTrendDto(
                    $"{g.Key.Year}-{g.Key.Month:D2}",
                    g.Count(),
                    g.Sum(s => s.LineTotal),
                    g.Sum(s => s.OrderQuantity)
                ))
                .OrderBy(s => s.Period)
                .ToList();
        }
    }
}
