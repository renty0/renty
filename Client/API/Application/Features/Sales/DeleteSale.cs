using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Sales;

public record DeleteSaleCommand(long Id) : IRequest<DeleteSaleResponse>;

public record DeleteSaleResponse(
    bool Success,
    string? Message
);

public class DeleteSaleCommandValidator : AbstractValidator<DeleteSaleCommand>
{
    public DeleteSaleCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid sale ID.");
    }
}

public class DeleteSaleCommandHandler : IRequestHandler<DeleteSaleCommand, DeleteSaleResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteSaleCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteSaleResponse> Handle(DeleteSaleCommand request, CancellationToken cancellationToken)
    {
        var sale = await _context.Sales
            .FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);

        if (sale == null)
        {
            return new DeleteSaleResponse(false, "Sale not found.");
        }

        _context.Sales.Remove(sale);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteSaleResponse(true, "Sale deleted successfully.");
    }
}
