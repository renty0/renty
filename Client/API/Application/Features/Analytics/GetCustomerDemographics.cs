using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Analytics;

public record GetCustomerDemographicsQuery() : IRequest<CustomerDemographicsDto>;

public class GetCustomerDemographicsQueryHandler : IRequestHandler<GetCustomerDemographicsQuery, CustomerDemographicsDto>
{
    private readonly IApplicationDbContext _context;

    public GetCustomerDemographicsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CustomerDemographicsDto> Handle(GetCustomerDemographicsQuery request, CancellationToken cancellationToken)
    {
        var customers = await _context.Customers.ToListAsync(cancellationToken);

        var genderBreakdown = customers
            .GroupBy(c => c.Gender ?? "Unknown")
            .Select(g => new CategoryCountDto(g.Key, g.Count()))
            .ToList();

        var occupationBreakdown = customers
            .GroupBy(c => c.Occupation ?? "Unknown")
            .Select(g => new CategoryCountDto(g.Key, g.Count()))
            .ToList();

        var educationBreakdown = customers
            .GroupBy(c => c.EducationLevel ?? "Unknown")
            .Select(g => new CategoryCountDto(g.Key, g.Count()))
            .ToList();

        var maritalBreakdown = customers
            .GroupBy(c => c.MaritalStatus ?? "Unknown")
            .Select(g => new CategoryCountDto(g.Key, g.Count()))
            .ToList();

        return new CustomerDemographicsDto(
            genderBreakdown,
            occupationBreakdown,
            educationBreakdown,
            maritalBreakdown
        );
    }
}
