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
    Task<Result> UpdateUserAsync(ApplicationUser user);
    Task<string> GenerateEmailConfirmationTokenAsync(ApplicationUser user);
    Task<Result> ConfirmEmailAsync(ApplicationUser user, string token);
    Task<string> GeneratePasswordResetTokenAsync(ApplicationUser user);
    Task<Result> ResetPasswordAsync(ApplicationUser user, string token, string newPassword);
    Task<bool> VerifyPasswordResetTokenAsync(ApplicationUser user, string token);
}
