using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Returns;

public record GetReturnsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    long? ProductId = null,
    int? TerritoryId = null
) : IRequest<GetReturnsResponse>;

public record GetReturnsResponse(
    bool Success,
    string? Message,
    PaginatedList<ReturnListDto> Returns
);

public class GetReturnsQueryHandler : IRequestHandler<GetReturnsQuery, GetReturnsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetReturnsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetReturnsResponse> Handle(GetReturnsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Returns
            .Include(r => r.Product)
            .Include(r => r.Territory)
            .AsQueryable();

        if (request.StartDate.HasValue)
        {
            query = query.Where(r => r.ReturnDate >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            query = query.Where(r => r.ReturnDate <= request.EndDate.Value);
        }

        if (request.ProductId.HasValue)
        {
            query = query.Where(r => r.ProductId == request.ProductId.Value);
        }

        if (request.TerritoryId.HasValue)
        {
            query = query.Where(r => r.TerritoryId == request.TerritoryId.Value);
        }

        var projectedQuery = query
            .OrderByDescending(r => r.ReturnDate)
            .ThenByDescending(r => r.Id)
            .Select(r => new ReturnListDto(
                r.Id,
                r.ReturnDate,
                r.ReturnQuantity,
                r.Product.ProductName,
                r.Territory.Region
            ));

        var returns = await PaginatedList<ReturnListDto>.CreateAsync(
            projectedQuery,
            request.PageNumber,
            request.PageSize,
            cancellationToken
        );

        return new GetReturnsResponse(true, null, returns);
    }
}
