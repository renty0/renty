using Application.Common.Models;

namespace Application.Features.Dashboard;

public record AdminDashboardDto(
    int TotalUsers,
    int TotalOwners,
    int TotalRenters,
    int TotalItems,
    int TotalRentals,
    decimal TotalRevenue,
    List<RecentUserDto> RecentUsers,
    List<RentRequestListDto> RecentRentals
);

public record RecentUserDto(
    long Id,
    string Email,
    string FullName,
    string UserType,
    DateTimeOffset CreatedAt
);
