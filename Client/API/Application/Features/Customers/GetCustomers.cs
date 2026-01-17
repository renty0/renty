using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Customers;

public record GetCustomersQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? SearchTerm = null,
    string? Gender = null,
    string? Occupation = null
) : IRequest<GetCustomersResponse>;

public record GetCustomersResponse(
    bool Success,
    string? Message,
    PaginatedList<CustomerListDto> Customers
);

public class GetCustomersQueryHandler : IRequestHandler<GetCustomersQuery, GetCustomersResponse>
{
    private readonly IApplicationDbContext _context;

    public GetCustomersQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetCustomersResponse> Handle(GetCustomersQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Customers.AsQueryable();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var searchTerm = request.SearchTerm.ToLower();
            query = query.Where(c =>
                c.FirstName.ToLower().Contains(searchTerm) ||
                c.LastName.ToLower().Contains(searchTerm) ||
                (c.EmailAddress != null && c.EmailAddress.ToLower().Contains(searchTerm))
            );
        }

        if (!string.IsNullOrWhiteSpace(request.Gender))
        {
            query = query.Where(c => c.Gender == request.Gender);
        }

        if (!string.IsNullOrWhiteSpace(request.Occupation))
        {
            query = query.Where(c => c.Occupation == request.Occupation);
        }

        var projectedQuery = query
            .OrderByDescending(c => c.Created)
            .Select(c => new CustomerListDto(
                c.Id,
                string.IsNullOrEmpty(c.Prefix)
                    ? (c.FirstName + " " + c.LastName).Trim()
                    : (c.Prefix + " " + c.FirstName + " " + c.LastName).Trim(),
                c.EmailAddress,
                c.Gender,
                c.Occupation,
                c.DomainName
            ));

        var customers = await PaginatedList<CustomerListDto>.CreateAsync(
            projectedQuery,
            request.PageNumber,
            request.PageSize,
            cancellationToken
        );

        return new GetCustomersResponse(true, null, customers);
    }
}
