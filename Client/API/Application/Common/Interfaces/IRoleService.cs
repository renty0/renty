using Application.Common.Models;

namespace Application.Common.Interfaces;

public interface IRoleService
{
    // Role CRUD
    Task<(Result Result, long RoleId)> CreateRoleAsync(string name);
    Task<Result> UpdateRoleAsync(long roleId, string? name);
    Task<Result> DeleteRoleAsync(long roleId);
    Task<RoleDto?> GetRoleByIdAsync(long roleId);
    Task<List<RoleDto>> GetAllRolesAsync(CancellationToken cancellationToken = default);
    Task<bool> RoleExistsAsync(string roleName);
    
    // Role-Permissions
    Task<List<string>> GetPermissionsForRoleAsync(long roleId);
    Task<Result> UpdateRolePermissionsAsync(long roleId, List<string> permissionValues);
    Task<List<string>> GetUserPermissionsAsync(long userId);

    // User-Role operations
    Task<Result> AddUserToRoleAsync(long userId, string roleName);
    Task<Result> RemoveUserFromRoleAsync(long userId, string roleName);
    Task<Result> SetUserRolesAsync(long userId, List<string> roleNames);
    Task<List<long>> GetUserIdsInRoleAsync(string roleName);
    Task<List<PermissionMetadataDto>> GetAllPermissionsAsync();
}

public record RoleDto(long Id, string Name);
