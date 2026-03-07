using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Territories;

public record GetTerritoriesQuery(
    string? Continent = null,
    string? Country = null
) : IRequest<GetTerritoriesResponse>;

public record GetTerritoriesResponse(
    bool Success,
    string? Message,
    List<TerritoryDto> Territories
);

public class GetTerritoriesQueryHandler : IRequestHandler<GetTerritoriesQuery, GetTerritoriesResponse>
{
    private readonly IApplicationDbContext _context;

    public GetTerritoriesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetTerritoriesResponse> Handle(GetTerritoriesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Territories.AsQueryable();

        if (!string.IsNullOrWhiteSpace(request.Continent))
        {
            query = query.Where(t => t.Continent == request.Continent);
        }

        if (!string.IsNullOrWhiteSpace(request.Country))
        {
            query = query.Where(t => t.Country == request.Country);
        }

        var territories = await query
            .OrderBy(t => t.Continent)
            .ThenBy(t => t.Country)
            .ThenBy(t => t.Region)
            .Select(t => new TerritoryDto(
                t.Id,
                t.Region,
                t.Country,
                t.Continent
            ))
            .ToListAsync(cancellationToken);

        return new GetTerritoriesResponse(true, null, territories);
    }
}
