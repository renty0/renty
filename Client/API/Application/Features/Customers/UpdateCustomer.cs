using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Customers;

public record UpdateCustomerCommand(
    long Id,
    string? Prefix,
    string FirstName,
    string LastName,
    DateOnly? BirthDate,
    string? MaritalStatus,
    string? Gender,
    string? EmailAddress,
    decimal? AnnualIncome,
    int? TotalChildren,
    string? EducationLevel,
    string? Occupation,
    bool? HomeOwner,
    string? DomainName
) : IRequest<UpdateCustomerResponse>;

public record UpdateCustomerResponse(
    bool Success,
    string? Message,
    CustomerDto? Customer
);

public class UpdateCustomerCommandValidator : AbstractValidator<UpdateCustomerCommand>
{
    public UpdateCustomerCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid customer ID.");

        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("First name is required.")
            .MaximumLength(100).WithMessage("First name must not exceed 100 characters.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Last name is required.")
            .MaximumLength(100).WithMessage("Last name must not exceed 100 characters.");

        RuleFor(x => x.EmailAddress)
            .EmailAddress().When(x => !string.IsNullOrEmpty(x.EmailAddress))
            .WithMessage("Invalid email format.");
    }
}

public class UpdateCustomerCommandHandler : IRequestHandler<UpdateCustomerCommand, UpdateCustomerResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateCustomerCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateCustomerResponse> Handle(UpdateCustomerCommand request, CancellationToken cancellationToken)
    {
        var customer = await _context.Customers
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);

        if (customer == null)
        {
            return new UpdateCustomerResponse(false, "Customer not found.", null);
        }

        customer.Prefix = request.Prefix;
        customer.FirstName = request.FirstName;
        customer.LastName = request.LastName;
        customer.BirthDate = request.BirthDate;
        customer.MaritalStatus = request.MaritalStatus;
        customer.Gender = request.Gender;
        customer.EmailAddress = request.EmailAddress;
        customer.AnnualIncome = request.AnnualIncome;
        customer.TotalChildren = request.TotalChildren;
        customer.EducationLevel = request.EducationLevel;
        customer.Occupation = request.Occupation;
        customer.HomeOwner = request.HomeOwner;
        customer.DomainName = request.DomainName;

        await _context.SaveChangesAsync(cancellationToken);

        var dto = new CustomerDto(
            customer.Id,
            customer.Prefix,
            customer.FirstName,
            customer.LastName,
            customer.FullName,
            customer.BirthDate,
            customer.MaritalStatus,
            customer.Gender,
            customer.EmailAddress,
            customer.AnnualIncome,
            customer.TotalChildren,
            customer.EducationLevel,
            customer.Occupation,
            customer.HomeOwner,
            customer.DomainName
        );

        return new UpdateCustomerResponse(true, "Customer updated successfully.", dto);
    }
}
