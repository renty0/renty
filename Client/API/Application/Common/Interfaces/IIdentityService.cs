using Application.Common.Models;
using Domain.Entities;

namespace Application.Common.Interfaces;

public interface IIdentityService
{
    Task<ApplicationUser?> GetUserByEmailAsync(string email);
    Task<ApplicationUser?> GetUserByIdAsync(long userId);
    Task<bool> ValidatePasswordAsync(ApplicationUser user, string password);
    Task<IList<string>> GetUserRolesAsync(ApplicationUser user);
    Task<Result> CreateUserAsync(ApplicationUser user, string password);
    Task<Result> AddToRoleAsync(ApplicationUser user, string role);
    Task UpdateLastLoginAsync(ApplicationUser user);
}
