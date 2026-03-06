using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record UpdateSaleCommand(
    long Id,
    DateOnly OrderDate,
    DateOnly? StockDate,
    string OrderNumber,
    int OrderLineItem,
    int OrderQuantity,
    long ProductId,
    long CustomerId,
    int TerritoryId
) : IRequest<UpdateSaleResponse>;

public record UpdateSaleResponse(
    bool Success,
    string? Message,
    SaleDto? Sale
);

public class UpdateSaleCommandValidator : AbstractValidator<UpdateSaleCommand>
{
    public UpdateSaleCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid sale ID.");

        RuleFor(x => x.OrderNumber)
            .NotEmpty().WithMessage("Order number is required.")
            .MaximumLength(50).WithMessage("Order number must not exceed 50 characters.");

        RuleFor(x => x.OrderQuantity)
            .GreaterThan(0).WithMessage("Order quantity must be greater than 0.");

        RuleFor(x => x.ProductId)
            .GreaterThan(0).WithMessage("Invalid product ID.");

        RuleFor(x => x.CustomerId)
            .GreaterThan(0).WithMessage("Invalid customer ID.");

        RuleFor(x => x.TerritoryId)
            .GreaterThan(0).WithMessage("Invalid territory ID.");
    }
}

public class UpdateSaleCommandHandler : IRequestHandler<UpdateSaleCommand, UpdateSaleResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateSaleCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateSaleResponse> Handle(UpdateSaleCommand request, CancellationToken cancellationToken)
    {
        var sale = await _context.Sales
            .FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);

        if (sale == null)
        {
            return new UpdateSaleResponse(false, "Sale not found.", null);
        }

        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == request.ProductId, cancellationToken);

        if (product == null)
        {
            return new UpdateSaleResponse(false, "Product not found.", null);
        }

        var customer = await _context.Customers
            .FirstOrDefaultAsync(c => c.Id == request.CustomerId, cancellationToken);

        if (customer == null)
        {
            return new UpdateSaleResponse(false, "Customer not found.", null);
        }

        var territory = await _context.Territories
            .FirstOrDefaultAsync(t => t.Id == request.TerritoryId, cancellationToken);

        if (territory == null)
        {
            return new UpdateSaleResponse(false, "Territory not found.", null);
        }

        sale.OrderDate = request.OrderDate;
        sale.StockDate = request.StockDate;
        sale.OrderNumber = request.OrderNumber;
        sale.OrderLineItem = request.OrderLineItem;
        sale.OrderQuantity = request.OrderQuantity;
        sale.ProductId = request.ProductId;
        sale.CustomerId = request.CustomerId;
        sale.TerritoryId = request.TerritoryId;

        await _context.SaveChangesAsync(cancellationToken);

        var effectivePrice = product.DiscountPrice ?? product.ProductPrice;
        var dto = new SaleDto(
            sale.Id,
            sale.OrderDate,
            sale.StockDate,
            sale.OrderNumber,
            sale.OrderLineItem,
            sale.OrderQuantity,
            sale.ProductId,
            product.NameAr,
            product.NameEn,
            effectivePrice,
            sale.CustomerId,
            customer.FullName,
            sale.TerritoryId,
            territory.Region,
            territory.Country,
            sale.OrderQuantity * effectivePrice
        );

        return new UpdateSaleResponse(true, "Sale updated successfully.", dto);
    }
}
