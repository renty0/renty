using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Dashboard;

public record GetAdminDashboardQuery : IRequest<AdminDashboardDto>;

public class GetAdminDashboardQueryHandler : IRequestHandler<GetAdminDashboardQuery, AdminDashboardDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IIdentityService _identityService;

    public GetAdminDashboardQueryHandler(IApplicationDbContext context, IIdentityService identityService)
    {
        _context = context;
        _identityService = identityService;
    }

    public async Task<AdminDashboardDto> Handle(GetAdminDashboardQuery request, CancellationToken cancellationToken)
    {
        var totalUsers = await _context.Customers.CountAsync(cancellationToken);
        // This is a simplified count, in a real app we'd check roles/usertype in Identity
        // But since we have Customer entity, let's use it for stats.
        
        var totalItems = await _context.RentableItems.CountAsync(cancellationToken);
        var totalRentals = await _context.RentRequests.CountAsync(x => x.Status == RentRequestStatus.Active || x.Status == RentRequestStatus.Completed, cancellationToken);
        var totalRevenue = await _context.RentRequests
            .Where(x => x.Status == RentRequestStatus.Completed)
            .SumAsync(x => x.TotalAmount, cancellationToken);

        var recentUsers = await _context.Customers
            .OrderByDescending(x => x.Created)
            .Take(5)
            .Select(x => new RecentUserDto(x.Id, x.EmailAddress ?? "", x.FullName, "Customer", x.Created))
            .ToListAsync(cancellationToken);

        var recentRentals = await _context.RentRequests
            .Include(x => x.RentableItem)
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
                x.RentableItem.Images.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).FirstOrDefault(),
                "User", // Simplified
                "Owner", // Simplified
                x.Created
            ))
            .ToListAsync(cancellationToken);

        return new AdminDashboardDto(
            totalUsers,
            0, // Simplified
            0, // Simplified
            totalItems,
            totalRentals,
            totalRevenue,
            recentUsers,
            recentRentals
        );
    }
}
