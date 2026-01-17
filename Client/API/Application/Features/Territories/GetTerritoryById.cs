using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Territories;

public record GetTerritoryByIdQuery(int Id) : IRequest<GetTerritoryByIdResponse>;

public record GetTerritoryByIdResponse(
    bool Success,
    string? Message,
    TerritoryDto? Territory
);

public class GetTerritoryByIdQueryHandler : IRequestHandler<GetTerritoryByIdQuery, GetTerritoryByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetTerritoryByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetTerritoryByIdResponse> Handle(GetTerritoryByIdQuery request, CancellationToken cancellationToken)
    {
        var territory = await _context.Territories
            .Where(t => t.Id == request.Id)
            .Select(t => new TerritoryDto(
                t.Id,
                t.Region,
                t.Country,
                t.Continent
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (territory == null)
        {
            return new GetTerritoryByIdResponse(false, "Territory not found.", null);
        }

        return new GetTerritoryByIdResponse(true, null, territory);
    }
}
