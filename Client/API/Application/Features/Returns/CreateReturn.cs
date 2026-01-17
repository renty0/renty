using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Returns;

public record CreateReturnCommand(
    DateOnly ReturnDate,
    int ReturnQuantity,
    string? ReturnReason,
    long ProductId,
    int TerritoryId
) : IRequest<CreateReturnResponse>;

public record CreateReturnResponse(
    bool Success,
    string? Message,
    ReturnDto? Return
);

public class CreateReturnCommandValidator : AbstractValidator<CreateReturnCommand>
{
    public CreateReturnCommandValidator()
    {
        RuleFor(x => x.ReturnQuantity)
            .GreaterThan(0).WithMessage("Return quantity must be greater than 0.");

        RuleFor(x => x.ReturnReason)
            .MaximumLength(500).WithMessage("Return reason must not exceed 500 characters.");

        RuleFor(x => x.ProductId)
            .GreaterThan(0).WithMessage("Invalid product ID.");

        RuleFor(x => x.TerritoryId)
            .GreaterThan(0).WithMessage("Invalid territory ID.");
    }
}

public class CreateReturnCommandHandler : IRequestHandler<CreateReturnCommand, CreateReturnResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateReturnCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateReturnResponse> Handle(CreateReturnCommand request, CancellationToken cancellationToken)
    {
        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == request.ProductId, cancellationToken);

        if (product == null)
        {
            return new CreateReturnResponse(false, "Product not found.", null);
        }

        var territory = await _context.Territories
            .FirstOrDefaultAsync(t => t.Id == request.TerritoryId, cancellationToken);

        if (territory == null)
        {
            return new CreateReturnResponse(false, "Territory not found.", null);
        }

        var returnCalendar = await _context.Calendars
            .FirstOrDefaultAsync(c => c.Date == request.ReturnDate, cancellationToken);

        if (returnCalendar == null)
        {
            return new CreateReturnResponse(false, "Return date not found in calendar. Please ensure the calendar is seeded.", null);
        }

        var returnItem = new Return
        {
            ReturnDate = request.ReturnDate,
            ReturnQuantity = request.ReturnQuantity,
            ReturnReason = request.ReturnReason,
            ProductId = request.ProductId,
            TerritoryId = request.TerritoryId
        };

        _context.Returns.Add(returnItem);
        await _context.SaveChangesAsync(cancellationToken);

        var effectivePrice = product.DiscountPrice ?? product.ProductPrice;
        var dto = new ReturnDto(
            returnItem.Id,
            returnItem.ReturnDate,
            returnItem.ReturnQuantity,
            returnItem.ReturnReason,
            returnItem.ProductId,
            product.ProductName,
            returnItem.TerritoryId,
            territory.Region,
            territory.Country,
            returnItem.ReturnQuantity * effectivePrice
        );

        return new CreateReturnResponse(true, "Return created successfully.", dto);
    }
}
