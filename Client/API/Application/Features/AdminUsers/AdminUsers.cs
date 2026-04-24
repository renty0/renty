using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.AdminUsers;
public record AdminUserDto(
    long Id,
    string FirstName,
    string LastName,
    string? Email,
    List<string> Roles,
    bool IsVerified,
    bool IsActive,
    DateTimeOffset CreatedAt
);
public record GetAdminUsersQuery(int Page = 1, int Limit = 20, string? SearchTerm = null) : IRequest<GetAdminUsersResponse>;
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
        var query = _userManager.Users.AsQueryable();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.ToLower();
            query = query.Where(u => 
                (u.FirstName != null && u.FirstName.ToLower().Contains(search)) || 
                (u.LastName != null && u.LastName.ToLower().Contains(search)) || 
                (u.Email != null && u.Email.ToLower().Contains(search))
            );
        }

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var users = await query
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
                roles.ToList(),
                user.IsVerified,
                user.IsActive,
                user.CreatedAt
            ));
        }

        return new GetAdminUsersResponse(dtos, total, request.Page, pages);
    }
}
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
public record CreateAdminUserCommand(
    string Email,
    string Password,
    string FirstName,
    string LastName,
    List<string> Roles
) : IRequest<CreateAdminUserResponse>;

public record CreateAdminUserResponse(bool Success, string? Error, long? UserId);

public class CreateAdminUserCommandHandler : IRequestHandler<CreateAdminUserCommand, CreateAdminUserResponse>
{
    private readonly Microsoft.AspNetCore.Identity.UserManager<Domain.Entities.ApplicationUser> _userManager;
    private readonly IIdentityService _identityService;

    public CreateAdminUserCommandHandler(
        Microsoft.AspNetCore.Identity.UserManager<Domain.Entities.ApplicationUser> userManager,
        IIdentityService identityService)
    {
        _userManager = userManager;
        _identityService = identityService;
    }

    public async Task<CreateAdminUserResponse> Handle(CreateAdminUserCommand request, CancellationToken ct)
    {
        var existingUser = await _userManager.FindByEmailAsync(request.Email);
        if (existingUser != null)
            return new CreateAdminUserResponse(false, "User with this email already exists.", null);

        var user = new Domain.Entities.ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            FirstName = request.FirstName,
            LastName = request.LastName,
            EmailConfirmed = true,
            IsActive = true,
            IsVerified = true,
            CreatedAt = DateTimeOffset.UtcNow,
            UserType = Domain.Enums.UserType.Both
        };

        var result = await _userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
            return new CreateAdminUserResponse(false, string.Join("; ", result.Errors.Select(e => e.Description)), null);

        if (request.Roles != null && request.Roles.Any())
        {
            var roleResult = await _userManager.AddToRolesAsync(user, request.Roles);
            if (!roleResult.Succeeded)
                return new CreateAdminUserResponse(false, "User created but failed to assign roles: " + string.Join("; ", roleResult.Errors.Select(e => e.Description)), user.Id);
        }

        return new CreateAdminUserResponse(true, null, user.Id);
    }
}

public record AssignUserRolesCommand(long UserId, List<string> Roles) : IRequest<Application.Common.Models.Result>;

public class AssignUserRolesCommandHandler : IRequestHandler<AssignUserRolesCommand, Application.Common.Models.Result>
{
    private readonly IRoleService _roleService;

    public AssignUserRolesCommandHandler(IRoleService roleService)
    {
        _roleService = roleService;
    }

    public async Task<Application.Common.Models.Result> Handle(AssignUserRolesCommand request, CancellationToken ct)
    {
        return await _roleService.SetUserRolesAsync(request.UserId, request.Roles);
    }
}
