using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Customers;

public record GetCustomerByIdQuery(long Id) : IRequest<GetCustomerByIdResponse>;

public record GetCustomerByIdResponse(
    bool Success,
    string? Message,
    CustomerDto? Customer
);

public class GetCustomerByIdQueryHandler : IRequestHandler<GetCustomerByIdQuery, GetCustomerByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetCustomerByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetCustomerByIdResponse> Handle(GetCustomerByIdQuery request, CancellationToken cancellationToken)
    {
        var customer = await _context.Customers
            .Where(c => c.Id == request.Id)
            .Select(c => new CustomerDto(
                c.Id,
                c.Prefix,
                c.FirstName,
                c.LastName,
                string.IsNullOrEmpty(c.Prefix)
                    ? (c.FirstName + " " + c.LastName).Trim()
                    : (c.Prefix + " " + c.FirstName + " " + c.LastName).Trim(),
                c.BirthDate,
                c.MaritalStatus,
                c.Gender,
                c.EmailAddress,
                c.AnnualIncome,
                c.TotalChildren,
                c.EducationLevel,
                c.Occupation,
                c.HomeOwner,
                c.DomainName
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (customer == null)
        {
            return new GetCustomerByIdResponse(false, "Customer not found.", null);
        }

        return new GetCustomerByIdResponse(true, null, customer);
    }
}
