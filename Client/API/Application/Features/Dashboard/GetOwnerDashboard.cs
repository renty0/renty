using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Dashboard;

public record GetOwnerDashboardQuery : IRequest<OwnerDashboardDto>;

public class GetOwnerDashboardQueryHandler : IRequestHandler<GetOwnerDashboardQuery, OwnerDashboardDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetOwnerDashboardQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<OwnerDashboardDto> Handle(GetOwnerDashboardQuery request, CancellationToken cancellationToken)
    {
        var ownerId = _currentUser.Id ?? 0;

        var items = await _context.RentableItems
            .Where(x => x.OwnerId == ownerId)
            .ToListAsync(cancellationToken);

        var totalItems = items.Count;
        var availableItems = items.Count(x => x.Status == ItemStatus.Available);
        var rentedItems = items.Count(x => x.Status == ItemStatus.Rented);

        var requests = await _context.RentRequests
            .Where(x => x.RentableItem.OwnerId == ownerId)
            .ToListAsync(cancellationToken);

        var pendingRequests = requests.Count(x => x.Status == RentRequestStatus.Pending);
        var activeRentals = requests.Count(x => x.Status == RentRequestStatus.Active);
        var totalEarnings = requests.Where(x => x.Status == RentRequestStatus.Completed).Sum(x => x.TotalAmount);

        var recentRequests = requests
            .OrderByDescending(x => x.Created)
            .Take(5)
            .Select(x => new RentRequestListDto(
                x.Id,
                x.StartDate,
                x.EndDate,
                x.TotalDays,
                x.TotalAmount + (x.DeliveryFee ?? 0),
                x.Status.ToString(),
                x.RentableItem.TitleEn,
                null,
                "Renter",
                "Owner",
                x.Created
            ))
            .ToList();

        return new OwnerDashboardDto(
            totalItems,
            availableItems,
            rentedItems,
            pendingRequests,
            activeRentals,
            totalEarnings,
            recentRequests
        );
    }
}
