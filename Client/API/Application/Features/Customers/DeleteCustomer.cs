using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Customers;

public record DeleteCustomerCommand(long Id) : IRequest<DeleteCustomerResponse>;

public record DeleteCustomerResponse(
    bool Success,
    string? Message
);

public class DeleteCustomerCommandValidator : AbstractValidator<DeleteCustomerCommand>
{
    public DeleteCustomerCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid customer ID.");
    }
}

public class DeleteCustomerCommandHandler : IRequestHandler<DeleteCustomerCommand, DeleteCustomerResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteCustomerCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteCustomerResponse> Handle(DeleteCustomerCommand request, CancellationToken cancellationToken)
    {
        var customer = await _context.Customers
            .Include(c => c.Sales)
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);

        if (customer == null)
        {
            return new DeleteCustomerResponse(false, "Customer not found.");
        }

        if (customer.Sales.Any())
        {
            return new DeleteCustomerResponse(false, "Cannot delete customer with existing sales records.");
        }

        _context.Customers.Remove(customer);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteCustomerResponse(true, "Customer deleted successfully.");
    }
}
