using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Returns;

public record UpdateReturnCommand(
    long Id,
    DateOnly ReturnDate,
    int ReturnQuantity,
    string? ReturnReason,
    long ProductId,
    int TerritoryId
) : IRequest<UpdateReturnResponse>;

public record UpdateReturnResponse(
    bool Success,
    string? Message,
    ReturnDto? Return
);

public class UpdateReturnCommandValidator : AbstractValidator<UpdateReturnCommand>
{
    public UpdateReturnCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid return ID.");

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

public class UpdateReturnCommandHandler : IRequestHandler<UpdateReturnCommand, UpdateReturnResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateReturnCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateReturnResponse> Handle(UpdateReturnCommand request, CancellationToken cancellationToken)
    {
        var returnItem = await _context.Returns
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (returnItem == null)
        {
            return new UpdateReturnResponse(false, "Return not found.", null);
        }

        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == request.ProductId, cancellationToken);

        if (product == null)
        {
            return new UpdateReturnResponse(false, "Product not found.", null);
        }

        var territory = await _context.Territories
            .FirstOrDefaultAsync(t => t.Id == request.TerritoryId, cancellationToken);

        if (territory == null)
        {
            return new UpdateReturnResponse(false, "Territory not found.", null);
        }

        returnItem.ReturnDate = request.ReturnDate;
        returnItem.ReturnQuantity = request.ReturnQuantity;
        returnItem.ReturnReason = request.ReturnReason;
        returnItem.ProductId = request.ProductId;
        returnItem.TerritoryId = request.TerritoryId;

        await _context.SaveChangesAsync(cancellationToken);

        var effectivePrice = product.RentDiscountPrice ?? product.RentPricePerDay;
        var dto = new ReturnDto(
            returnItem.Id,
            returnItem.ReturnDate,
            returnItem.ReturnQuantity,
            returnItem.ReturnReason,
            returnItem.ProductId,
            product.NameEn,
            returnItem.TerritoryId,
            territory.Region,
            territory.Country,
            returnItem.ReturnQuantity * effectivePrice
        );

        return new UpdateReturnResponse(true, "Return updated successfully.", dto);
    }
}
