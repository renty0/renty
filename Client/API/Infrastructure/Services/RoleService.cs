using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Services;

public class RoleService : IRoleService
{
    private readonly RoleManager<ApplicationRole> _roleManager;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IApplicationDbContext _context;

    public RoleService(
        RoleManager<ApplicationRole> roleManager,
        UserManager<ApplicationUser> userManager,
        IApplicationDbContext context)
    {
        _roleManager = roleManager;
        _userManager = userManager;
        _context = context;
    }

    public async Task<(Result Result, long RoleId)> CreateRoleAsync(string name)
    {
        var role = new ApplicationRole(name);
        var result = await _roleManager.CreateAsync(role);
        return (result.ToApplicationResult(), role.Id);
    }

    public async Task<Result> UpdateRoleAsync(long roleId, string? name)
    {
        var role = await _roleManager.FindByIdAsync(roleId.ToString());
        if (role == null) return Result.Failure("Role not found");

        if (!string.IsNullOrEmpty(name))
        {
            role.Name = name;
        }

        var result = await _roleManager.UpdateAsync(role);
        return result.ToApplicationResult();
    }

    public async Task<Result> DeleteRoleAsync(long roleId)
    {
        var role = await _roleManager.FindByIdAsync(roleId.ToString());
        if (role == null) return Result.Failure("Role not found");

        var result = await _roleManager.DeleteAsync(role);
        return result.ToApplicationResult();
    }

    public async Task<RoleDto?> GetRoleByIdAsync(long roleId)
    {
        var role = await _roleManager.FindByIdAsync(roleId.ToString());
        return role != null ? new RoleDto(role.Id, role.Name!) : null;
    }

    public async Task<List<RoleDto>> GetAllRolesAsync(CancellationToken cancellationToken = default)
    {
        return await _roleManager.Roles
            .OrderBy(r => r.Name)
            .Select(r => new RoleDto(r.Id, r.Name!))
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> RoleExistsAsync(string roleName)
    {
        return await _roleManager.RoleExistsAsync(roleName);
    }

    public async Task<List<string>> GetPermissionsForRoleAsync(long roleId)
    {
        return await _context.RolePermissions
            .Where(rp => rp.RoleId == roleId)
            .Select(rp => rp.PermissionValue)
            .ToListAsync();
    }

    public async Task<Result> UpdateRolePermissionsAsync(long roleId, List<string> permissionValues)
    {
        var role = await _roleManager.FindByIdAsync(roleId.ToString());
        if (role == null) return Result.Failure("Role not found");

        // Remove existing
        var existing = await _context.RolePermissions
            .Where(rp => rp.RoleId == roleId)
            .ToListAsync();
        _context.RolePermissions.RemoveRange(existing);

        // Add new
        foreach (var val in permissionValues)
        {
            _context.RolePermissions.Add(new RolePermission
            {
                RoleId = roleId,
                RoleName = role.Name!,
                PermissionValue = val
            });
        }

        await _context.SaveChangesAsync();
        return Result.Success();
    }

    public async Task<List<string>> GetUserPermissionsAsync(long userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return new List<string>();

        var userRoles = await _userManager.GetRolesAsync(user);
        
        return await _context.RolePermissions
            .Where(rp => userRoles.Contains(rp.RoleName))
            .Select(rp => rp.PermissionValue)
            .Distinct()
            .ToListAsync();
    }

    public async Task<Result> AddUserToRoleAsync(long userId, string roleName)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return Result.Failure("User not found");

        var result = await _userManager.AddToRoleAsync(user, roleName);
        return result.ToApplicationResult();
    }

    public async Task<Result> RemoveUserFromRoleAsync(long userId, string roleName)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return Result.Failure("User not found");

        var result = await _userManager.RemoveFromRoleAsync(user, roleName);
        return result.ToApplicationResult();
    }

    public async Task<Result> SetUserRolesAsync(long userId, List<string> roleNames)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return Result.Failure("User not found");

        var currentRoles = await _userManager.GetRolesAsync(user);
        
        var removeResult = await _userManager.RemoveFromRolesAsync(user, currentRoles);
        if (!removeResult.Succeeded) return removeResult.ToApplicationResult();

        var addResult = await _userManager.AddToRolesAsync(user, roleNames);
        return addResult.ToApplicationResult();
    }

    public async Task<List<long>> GetUserIdsInRoleAsync(string roleName)
    {
        var users = await _userManager.GetUsersInRoleAsync(roleName);
        return users.Select(u => u.Id).ToList();
    }

    public async Task<List<PermissionMetadataDto>> GetAllPermissionsAsync()
    {
        var result = new List<PermissionMetadataDto>();
        var type = typeof(Domain.Enums.PermissionType);
        var fields = type.GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);

        var groups = new Dictionary<string, List<PermissionItemDto>>();

        foreach (var field in fields)
        {
            var permissionAttr = field.GetCustomAttributes(typeof(Domain.Attributes.PermissionAttribute), false)
                .Cast<Domain.Attributes.PermissionAttribute>()
                .FirstOrDefault();

            var enumMemberAttr = field.GetCustomAttributes(typeof(System.Runtime.Serialization.EnumMemberAttribute), false)
                .Cast<System.Runtime.Serialization.EnumMemberAttribute>()
                .FirstOrDefault();

            if (permissionAttr != null && enumMemberAttr != null)
            {
                if (!groups.ContainsKey(permissionAttr.Module))
                {
                    groups[permissionAttr.Module] = new List<PermissionItemDto>();
                }

                groups[permissionAttr.Module].Add(new PermissionItemDto(
                    enumMemberAttr.Value!,
                    permissionAttr.Action,
                    permissionAttr.Roles
                ));
            }
        }

        foreach (var group in groups)
        {
            result.Add(new PermissionMetadataDto(group.Key, group.Value));
        }

        return await Task.FromResult(result.OrderBy(x => x.Module).ToList());
    }
}
