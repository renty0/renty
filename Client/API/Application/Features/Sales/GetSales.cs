using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record GetSalesQuery(
    int PageNumber = 1,
    int PageSize = 10,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    long? CustomerId = null,
    long? ProductId = null,
    int? TerritoryId = null,
    string? OrderNumber = null
) : IRequest<GetSalesResponse>;

public record GetSalesResponse(
    bool Success,
    string? Message,
    PaginatedList<SaleListDto> Sales
);

public class GetSalesQueryHandler : IRequestHandler<GetSalesQuery, GetSalesResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSalesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetSalesResponse> Handle(GetSalesQuery request, CancellationToken cancellationToken)
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

        if (request.CustomerId.HasValue)
        {
            query = query.Where(s => s.CustomerId == request.CustomerId.Value);
        }

        if (request.ProductId.HasValue)
        {
            query = query.Where(s => s.ProductId == request.ProductId.Value);
        }

        if (request.TerritoryId.HasValue)
        {
            query = query.Where(s => s.TerritoryId == request.TerritoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.OrderNumber))
        {
            query = query.Where(s => s.OrderNumber.Contains(request.OrderNumber));
        }

        var projectedQuery = query
            .OrderByDescending(s => s.OrderDate)
            .ThenByDescending(s => s.Id)
            .Select(s => new SaleListDto(
                s.Id,
                s.OrderDate,
                s.OrderNumber,
                s.OrderQuantity,
                s.Product.NameEn,
                s.Customer.FirstName + " " + s.Customer.LastName,
                s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice)
            ));

        var sales = await PaginatedList<SaleListDto>.CreateAsync(
            projectedQuery,
            request.PageNumber,
            request.PageSize,
            cancellationToken
        );

        return new GetSalesResponse(true, null, sales);
    }
}
