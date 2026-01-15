using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Dashboard;

public record GetRenterDashboardQuery : IRequest<RenterDashboardDto>;

public class GetRenterDashboardQueryHandler : IRequestHandler<GetRenterDashboardQuery, RenterDashboardDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetRenterDashboardQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RenterDashboardDto> Handle(GetRenterDashboardQuery request, CancellationToken cancellationToken)
    {
        var renterId = _currentUser.Id ?? 0;

        var requests = await _context.RentRequests
            .Where(x => x.RenterId == renterId)
            .ToListAsync(cancellationToken);

        var totalRequests = requests.Count;
        var pendingRequests = requests.Count(x => x.Status == RentRequestStatus.Pending);
        var activeRentals = requests.Count(x => x.Status == RentRequestStatus.Active);
        var completedRentals = requests.Count(x => x.Status == RentRequestStatus.Completed);
        var totalSpent = requests.Where(x => x.Status == RentRequestStatus.Completed).Sum(x => x.TotalAmount);

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
                x.RentableItem.Title,
                null, // Simplified
                "Renter", // Simplified
                "Owner", // Simplified
                x.Created
            ))
            .ToList();

        return new RenterDashboardDto(
            totalRequests,
            pendingRequests,
            activeRentals,
            completedRentals,
            totalSpent,
            recentRequests
        );
    }
}
