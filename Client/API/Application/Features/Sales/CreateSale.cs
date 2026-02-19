using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record CreateSaleCommand(
    DateOnly OrderDate,
    DateOnly? StockDate,
    string OrderNumber,
    int OrderLineItem,
    int OrderQuantity,
    long ProductId,
    long CustomerId,
    int TerritoryId
) : IRequest<CreateSaleResponse>;

public record CreateSaleResponse(
    bool Success,
    string? Message,
    SaleDto? Sale
);

public class CreateSaleCommandValidator : AbstractValidator<CreateSaleCommand>
{
    public CreateSaleCommandValidator()
    {
        RuleFor(x => x.OrderNumber)
            .NotEmpty().WithMessage("Order number is required.")
            .MaximumLength(50).WithMessage("Order number must not exceed 50 characters.");

        RuleFor(x => x.OrderLineItem)
            .GreaterThan(0).WithMessage("Order line item must be greater than 0.");

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

public class CreateSaleCommandHandler : IRequestHandler<CreateSaleCommand, CreateSaleResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateSaleCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateSaleResponse> Handle(CreateSaleCommand request, CancellationToken cancellationToken)
    {
        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == request.ProductId, cancellationToken);

        if (product == null)
        {
            return new CreateSaleResponse(false, "Product not found.", null);
        }

        var customer = await _context.Customers
            .FirstOrDefaultAsync(c => c.Id == request.CustomerId, cancellationToken);

        if (customer == null)
        {
            return new CreateSaleResponse(false, "Customer not found.", null);
        }

        var territory = await _context.Territories
            .FirstOrDefaultAsync(t => t.Id == request.TerritoryId, cancellationToken);

        if (territory == null)
        {
            return new CreateSaleResponse(false, "Territory not found.", null);
        }

        var orderCalendar = await _context.Calendars
            .FirstOrDefaultAsync(c => c.Date == request.OrderDate, cancellationToken);

        if (orderCalendar == null)
        {
            return new CreateSaleResponse(false, "Order date not found in calendar. Please ensure the calendar is seeded.", null);
        }

        var sale = new Sale
        {
            OrderDate = request.OrderDate,
            StockDate = request.StockDate,
            OrderNumber = request.OrderNumber,
            OrderLineItem = request.OrderLineItem,
            OrderQuantity = request.OrderQuantity,
            ProductId = request.ProductId,
            CustomerId = request.CustomerId,
            TerritoryId = request.TerritoryId
        };

        _context.Sales.Add(sale);
        await _context.SaveChangesAsync(cancellationToken);

        var effectivePrice = product.RentDiscountPrice ?? product.RentPricePerDay;
        var dto = new SaleDto(
            sale.Id,
            sale.OrderDate,
            sale.StockDate,
            sale.OrderNumber,
            sale.OrderLineItem,
            sale.OrderQuantity,
            sale.ProductId,
            product.NameEn,
            effectivePrice,
            sale.CustomerId,
            customer.FullName,
            sale.TerritoryId,
            territory.Region,
            territory.Country,
            sale.OrderQuantity * effectivePrice
        );

        return new CreateSaleResponse(true, "Sale created successfully.", dto);
    }
}
