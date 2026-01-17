using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record GetRentRequestsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    RentRequestStatus? Status = null,
    bool AsOwner = false  // If true, get requests for owner's items; if false, get renter's requests
) : IRequest<GetRentRequestsResponse>;

public record GetRentRequestsResponse(
    bool Success,
    string? Message,
    PaginatedList<RentRequestListDto> Requests
);

public class GetRentRequestsQueryHandler : IRequestHandler<GetRentRequestsQuery, GetRentRequestsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetRentRequestsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetRentRequestsResponse> Handle(GetRentRequestsQuery request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new GetRentRequestsResponse(false, "User not authenticated.", null!);
        }

        var query = _context.RentRequests
            .Include(r => r.RentableItem)
            .ThenInclude(ri => ri.Images)
            .Include(r => r.RentableItem.Owner)
            .Include(r => r.Renter)
            .AsQueryable();

        if (request.AsOwner)
        {
            // Get requests for items owned by the current user
            query = query.Where(r => r.RentableItem.OwnerId == _currentUser.Id.Value);
        }
        else
        {
            // Get requests made by the current user
            query = query.Where(r => r.RenterId == _currentUser.Id.Value);
        }

        if (request.Status.HasValue)
        {
            query = query.Where(r => r.Status == request.Status.Value);
        }

        var projectedQuery = query
            .OrderByDescending(r => r.Created)
            .Select(r => new RentRequestListDto(
                r.Id,
                r.StartDate,
                r.EndDate,
                r.TotalDays,
                r.GrandTotal,
                r.Status.ToString(),
                r.RentableItem.Title,
                r.RentableItem.Images.Where(i => i.IsPrimary).Select(i => i.ImageUrl).FirstOrDefault()
                    ?? r.RentableItem.Images.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).FirstOrDefault(),
                r.Renter.FirstName + " " + r.Renter.LastName,
                r.RentableItem.Owner.FirstName + " " + r.RentableItem.Owner.LastName,
                r.Created
            ));

        var requests = await PaginatedList<RentRequestListDto>.CreateAsync(
            projectedQuery,
            request.PageNumber,
            request.PageSize,
            cancellationToken
        );

        return new GetRentRequestsResponse(true, null, requests);
    }
}
