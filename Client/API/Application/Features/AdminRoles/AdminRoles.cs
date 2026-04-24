using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;

namespace Application.Features.AdminRoles;

// GET All Roles
public record GetAdminRolesQuery() : IRequest<List<RoleDto>>;

public class GetAdminRolesQueryHandler : IRequestHandler<GetAdminRolesQuery, List<RoleDto>>
{
    private readonly IRoleService _roleService;
    public GetAdminRolesQueryHandler(IRoleService roleService) => _roleService = roleService;
    public async Task<List<RoleDto>> Handle(GetAdminRolesQuery request, CancellationToken cancellationToken)
        => await _roleService.GetAllRolesAsync(cancellationToken);
}

// GET Role Details
public record GetRoleDetailsQuery(long RoleId) : IRequest<RoleDetailsResponse>;

public record RoleDetailsResponse(long Id, string Name, List<string> Permissions);

public class GetRoleDetailsQueryHandler : IRequestHandler<GetRoleDetailsQuery, RoleDetailsResponse>
{
    private readonly IRoleService _roleService;
    public GetRoleDetailsQueryHandler(IRoleService roleService) => _roleService = roleService;
    public async Task<RoleDetailsResponse> Handle(GetRoleDetailsQuery request, CancellationToken cancellationToken)
    {
        var role = await _roleService.GetRoleByIdAsync(request.RoleId);
        if (role == null) return null!;
        var perms = await _roleService.GetPermissionsForRoleAsync(request.RoleId);
        return new RoleDetailsResponse(role.Id, role.Name, perms);
    }
}

// CREATE Role
public record CreateRoleCommand(string Name, List<string> Permissions) : IRequest<Result>;

public class CreateRoleCommandHandler : IRequestHandler<CreateRoleCommand, Result>
{
    private readonly IRoleService _roleService;
    public CreateRoleCommandHandler(IRoleService roleService) => _roleService = roleService;
    public async Task<Result> Handle(CreateRoleCommand request, CancellationToken cancellationToken)
    {
        var (result, roleId) = await _roleService.CreateRoleAsync(request.Name);
        if (!result.Succeeded) return result;
        return await _roleService.UpdateRolePermissionsAsync(roleId, request.Permissions);
    }
}

// UPDATE Role
public record UpdateRoleCommand(long Id, string Name, List<string> Permissions) : IRequest<Result>;

public class UpdateRoleCommandHandler : IRequestHandler<UpdateRoleCommand, Result>
{
    private readonly IRoleService _roleService;
    public UpdateRoleCommandHandler(IRoleService roleService) => _roleService = roleService;
    public async Task<Result> Handle(UpdateRoleCommand request, CancellationToken cancellationToken)
    {
        var result = await _roleService.UpdateRoleAsync(request.Id, request.Name);
        if (!result.Succeeded) return result;
        return await _roleService.UpdateRolePermissionsAsync(request.Id, request.Permissions);
    }
}

// DELETE Role
public record DeleteRoleCommand(long Id) : IRequest<Result>;

public class DeleteRoleCommandHandler : IRequestHandler<DeleteRoleCommand, Result>
{
    private readonly IRoleService _roleService;
    public DeleteRoleCommandHandler(IRoleService roleService) => _roleService = roleService;
    public async Task<Result> Handle(DeleteRoleCommand request, CancellationToken cancellationToken)
        => await _roleService.DeleteRoleAsync(request.Id);
}

// GET All Permissions (Metadata)
public record GetAvailablePermissionsQuery() : IRequest<List<PermissionMetadataDto>>;

public class GetAvailablePermissionsQueryHandler : IRequestHandler<GetAvailablePermissionsQuery, List<PermissionMetadataDto>>
{
    private readonly IRoleService _roleService;
    public GetAvailablePermissionsQueryHandler(IRoleService roleService) => _roleService = roleService;
    public async Task<List<PermissionMetadataDto>> Handle(GetAvailablePermissionsQuery request, CancellationToken cancellationToken)
        => await _roleService.GetAllPermissionsAsync();
}

// GET My Permissions
public record GetMyPermissionsQuery() : IRequest<List<string>>;

public class GetMyPermissionsQueryHandler : IRequestHandler<GetMyPermissionsQuery, List<string>>
{
    private readonly IRoleService _roleService;
    private readonly IUser _currentUser;

    public GetMyPermissionsQueryHandler(IRoleService roleService, IUser currentUser)
    {
        _roleService = roleService;
        _currentUser = currentUser;
    }

    public async Task<List<string>> Handle(GetMyPermissionsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUser.Id;
        if (userId == null) return new List<string>();
        return await _roleService.GetUserPermissionsAsync(userId.Value);
    }
}
