using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record GetTopCustomersQuery(
    int Top = 10,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? TerritoryId = null
) : IRequest<GetTopCustomersResponse>;

public record GetTopCustomersResponse(
    bool Success,
    string? Message,
    List<TopCustomerDto> Customers
);

public class GetTopCustomersQueryHandler : IRequestHandler<GetTopCustomersQuery, GetTopCustomersResponse>
{
    private readonly IApplicationDbContext _context;

    public GetTopCustomersQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetTopCustomersResponse> Handle(GetTopCustomersQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Sales
            .Include(s => s.Product)
            .Include(s => s.Customer)
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

        var customers = await query
            .GroupBy(s => new { s.CustomerId, s.Customer.FirstName, s.Customer.LastName })
            .Select(g => new TopCustomerDto(
                g.Key.CustomerId,
                g.Key.FirstName + " " + g.Key.LastName,
                g.Select(s => s.OrderNumber).Distinct().Count(),
                g.Sum(s => s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice))
            ))
            .OrderByDescending(c => c.TotalSpent)
            .Take(request.Top)
            .ToListAsync(cancellationToken);

        return new GetTopCustomersResponse(true, null, customers);
    }
}
