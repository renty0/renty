using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record GetSaleByIdQuery(long Id) : IRequest<GetSaleByIdResponse>;

public record GetSaleByIdResponse(
    bool Success,
    string? Message,
    SaleDto? Sale
);

public class GetSaleByIdQueryHandler : IRequestHandler<GetSaleByIdQuery, GetSaleByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSaleByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetSaleByIdResponse> Handle(GetSaleByIdQuery request, CancellationToken cancellationToken)
    {
        var sale = await _context.Sales
            .Include(s => s.Product)
            .Include(s => s.Customer)
            .Include(s => s.Territory)
            .Where(s => s.Id == request.Id)
            .Select(s => new SaleDto(
                s.Id,
                s.OrderDate,
                s.StockDate,
                s.OrderNumber,
                s.OrderLineItem,
                s.OrderQuantity,
                s.ProductId,
                s.Product.ProductName,
                s.Product.DiscountPrice ?? s.Product.ProductPrice,
                s.CustomerId,
                s.Customer.FirstName + " " + s.Customer.LastName,
                s.TerritoryId,
                s.Territory.Region,
                s.Territory.Country,
                s.OrderQuantity * (s.Product.DiscountPrice ?? s.Product.ProductPrice)
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (sale == null)
        {
            return new GetSaleByIdResponse(false, "Sale not found.", null);
        }

        return new GetSaleByIdResponse(true, null, sale);
    }
}
