using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;

namespace Application.Features.Customers;

public record CreateCustomerCommand(
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
) : IRequest<CreateCustomerResponse>;

public record CreateCustomerResponse(
    bool Success,
    string? Message,
    CustomerDto? Customer
);

public class CreateCustomerCommandValidator : AbstractValidator<CreateCustomerCommand>
{
    public CreateCustomerCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("First name is required.")
            .MaximumLength(100).WithMessage("First name must not exceed 100 characters.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Last name is required.")
            .MaximumLength(100).WithMessage("Last name must not exceed 100 characters.");

        RuleFor(x => x.Prefix)
            .MaximumLength(10).WithMessage("Prefix must not exceed 10 characters.");

        RuleFor(x => x.EmailAddress)
            .EmailAddress().When(x => !string.IsNullOrEmpty(x.EmailAddress))
            .WithMessage("Invalid email format.")
            .MaximumLength(256).WithMessage("Email must not exceed 256 characters.");

        RuleFor(x => x.Gender)
            .MaximumLength(10).WithMessage("Gender must not exceed 10 characters.");

        RuleFor(x => x.MaritalStatus)
            .MaximumLength(20).WithMessage("Marital status must not exceed 20 characters.");

        RuleFor(x => x.EducationLevel)
            .MaximumLength(50).WithMessage("Education level must not exceed 50 characters.");

        RuleFor(x => x.Occupation)
            .MaximumLength(100).WithMessage("Occupation must not exceed 100 characters.");

        RuleFor(x => x.AnnualIncome)
            .GreaterThanOrEqualTo(0).When(x => x.AnnualIncome.HasValue)
            .WithMessage("Annual income must be non-negative.");

        RuleFor(x => x.TotalChildren)
            .GreaterThanOrEqualTo(0).When(x => x.TotalChildren.HasValue)
            .WithMessage("Total children must be non-negative.");
    }
}

public class CreateCustomerCommandHandler : IRequestHandler<CreateCustomerCommand, CreateCustomerResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateCustomerCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateCustomerResponse> Handle(CreateCustomerCommand request, CancellationToken cancellationToken)
    {
        var customer = new Customer
        {
            Prefix = request.Prefix,
            FirstName = request.FirstName,
            LastName = request.LastName,
            BirthDate = request.BirthDate,
            MaritalStatus = request.MaritalStatus,
            Gender = request.Gender,
            EmailAddress = request.EmailAddress,
            AnnualIncome = request.AnnualIncome,
            TotalChildren = request.TotalChildren,
            EducationLevel = request.EducationLevel,
            Occupation = request.Occupation,
            HomeOwner = request.HomeOwner,
            DomainName = request.DomainName
        };

        _context.Customers.Add(customer);
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

        return new CreateCustomerResponse(true, "Customer created successfully.", dto);
    }
}
