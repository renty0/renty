using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public enum PeriodType
{
    Monthly,
    Quarterly,
    Yearly
}

public record GetSalesByPeriodQuery(
    PeriodType Period = PeriodType.Monthly,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? TerritoryId = null
) : IRequest<GetSalesByPeriodResponse>;

public record GetSalesByPeriodResponse(
    bool Success,
    string? Message,
    List<SalesByPeriodDto> Data
);

public class GetSalesByPeriodQueryHandler : IRequestHandler<GetSalesByPeriodQuery, GetSalesByPeriodResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSalesByPeriodQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetSalesByPeriodResponse> Handle(GetSalesByPeriodQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Sales
            .Include(s => s.Product)
            .Include(s => s.OrderCalendar)
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

        List<SalesByPeriodDto> data;

        switch (request.Period)
        {
            case PeriodType.Monthly:
                data = await query
                    .GroupBy(s => new { s.OrderCalendar.Year, s.OrderCalendar.Month })
                    .Select(g => new SalesByPeriodDto(
                        g.Key.Year,
                        g.Key.Month,
                        null,
                        g.Sum(s => s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice)),
                        g.Select(s => s.OrderNumber).Distinct().Count(),
                        g.Sum(s => s.OrderQuantity)
                    ))
                    .OrderBy(x => x.Year)
                    .ThenBy(x => x.Month)
                    .ToListAsync(cancellationToken);
                break;

            case PeriodType.Quarterly:
                data = await query
                    .GroupBy(s => new { s.OrderCalendar.Year, s.OrderCalendar.Quarter })
                    .Select(g => new SalesByPeriodDto(
                        g.Key.Year,
                        null,
                        g.Key.Quarter,
                        g.Sum(s => s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice)),
                        g.Select(s => s.OrderNumber).Distinct().Count(),
                        g.Sum(s => s.OrderQuantity)
                    ))
                    .OrderBy(x => x.Year)
                    .ThenBy(x => x.Quarter)
                    .ToListAsync(cancellationToken);
                break;

            case PeriodType.Yearly:
            default:
                data = await query
                    .GroupBy(s => s.OrderCalendar.Year)
                    .Select(g => new SalesByPeriodDto(
                        g.Key,
                        null,
                        null,
                        g.Sum(s => s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice)),
                        g.Select(s => s.OrderNumber).Distinct().Count(),
                        g.Sum(s => s.OrderQuantity)
                    ))
                    .OrderBy(x => x.Year)
                    .ToListAsync(cancellationToken);
                break;
        }

        return new GetSalesByPeriodResponse(true, null, data);
    }
}
