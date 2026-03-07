using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.AdminUsers;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record AdminUserDto(
    long Id,
    string FirstName,
    string LastName,
    string? Email,
    string? Role,
    bool IsVerified,
    bool IsActive,
    DateTimeOffset CreatedAt
);

// ── GET USERS ─────────────────────────────────────────────────────────────────

public record GetAdminUsersQuery(int Page = 1, int Limit = 20) : IRequest<GetAdminUsersResponse>;
public record GetAdminUsersResponse(List<AdminUserDto> Users, int Total, int Page, int Pages);

public class GetAdminUsersQueryHandler : IRequestHandler<GetAdminUsersQuery, GetAdminUsersResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly Microsoft.AspNetCore.Identity.UserManager<Domain.Entities.ApplicationUser> _userManager;

    public GetAdminUsersQueryHandler(
        IApplicationDbContext context,
        Microsoft.AspNetCore.Identity.UserManager<Domain.Entities.ApplicationUser> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    public async Task<GetAdminUsersResponse> Handle(GetAdminUsersQuery request, CancellationToken ct)
    {
        var total = await _userManager.Users.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var users = await _userManager.Users
            .OrderByDescending(u => u.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .ToListAsync(ct);

        var dtos = new List<AdminUserDto>();
        foreach (var user in users)
        {
            var roles = await _userManager.GetRolesAsync(user);
            dtos.Add(new AdminUserDto(
                user.Id,
                user.FirstName,
                user.LastName,
                user.Email,
                roles.FirstOrDefault(),
                user.IsVerified,
                user.IsActive,
                user.CreatedAt
            ));
        }

        return new GetAdminUsersResponse(dtos, total, request.Page, pages);
    }
}

// ── UPDATE USER STATUS ────────────────────────────────────────────────────────

public record UpdateUserStatusCommand(long UserId, bool IsActive) : IRequest<UpdateUserStatusResponse>;
public record UpdateUserStatusResponse(bool Success, string? Error, long? UserId, bool? IsActive);

public class UpdateUserStatusCommandHandler : IRequestHandler<UpdateUserStatusCommand, UpdateUserStatusResponse>
{
    private readonly Microsoft.AspNetCore.Identity.UserManager<Domain.Entities.ApplicationUser> _userManager;

    public UpdateUserStatusCommandHandler(
        Microsoft.AspNetCore.Identity.UserManager<Domain.Entities.ApplicationUser> userManager)
    {
        _userManager = userManager;
    }

    public async Task<UpdateUserStatusResponse> Handle(UpdateUserStatusCommand request, CancellationToken ct)
    {
        var user = await _userManager.FindByIdAsync(request.UserId.ToString());
        if (user == null) return new UpdateUserStatusResponse(false, "User not found.", null, null);

        user.IsActive = request.IsActive;
        var result = await _userManager.UpdateAsync(user);

        if (!result.Succeeded)
            return new UpdateUserStatusResponse(false, string.Join("; ", result.Errors.Select(e => e.Description)), null, null);

        return new UpdateUserStatusResponse(true, null, user.Id, user.IsActive);
    }
}
