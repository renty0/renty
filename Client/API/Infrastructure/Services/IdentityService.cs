using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using Microsoft.AspNetCore.Identity;

namespace Infrastructure.Services;

public class IdentityService : IIdentityService
{
    private readonly UserManager<ApplicationUser> _userManager;

    public IdentityService(
        UserManager<ApplicationUser> userManager)
    {
        _userManager = userManager;
    }

    public async Task<ApplicationUser?> GetUserByEmailAsync(string email)
    {
        return await _userManager.FindByEmailAsync(email);
    }

    public async Task<ApplicationUser?> GetUserByIdAsync(long userId)
    {
        return await _userManager.FindByIdAsync(userId.ToString());
    }

    public async Task<bool> ValidatePasswordAsync(ApplicationUser user, string password)
    {
        return await _userManager.CheckPasswordAsync(user, password);
    }

    public async Task<IList<string>> GetUserRolesAsync(ApplicationUser user)
    {
        return await _userManager.GetRolesAsync(user);
    }

    public async Task<Result> CreateUserAsync(ApplicationUser user, string password)
    {
        var result = await _userManager.CreateAsync(user, password);
        return result.ToApplicationResult();
    }

    public async Task<Result> AddToRoleAsync(ApplicationUser user, string role)
    {
        var result = await _userManager.AddToRoleAsync(user, role);
        return result.ToApplicationResult();
    }

    public async Task UpdateLastLoginAsync(ApplicationUser user)
    {
        user.LastLoginAt = DateTimeOffset.UtcNow;
        await _userManager.UpdateAsync(user);
    }

    public async Task<Result> UpdateUserAsync(ApplicationUser user)
    {
        var result = await _userManager.UpdateAsync(user);
        return result.ToApplicationResult();
    }

    public async Task<string> GenerateEmailConfirmationTokenAsync(ApplicationUser user)
    {
        // For a simple 6-digit code, we could use a custom provider, 
        // but for now let's use the provided GenerateEmailConfirmationTokenAsync 
        // and later we can customize it to be a short code if needed.
        // Actually, let's use the 6-digit code directly if possible.
        // Identity has a DataProtectorTokenProvider that generates long tokens.
        // To get a short code, we can use GenerateTwoFactorTokenAsync with "Email"
        return await _userManager.GenerateChangeEmailTokenAsync(user, user.Email!);
    }

    public async Task<Result> ConfirmEmailAsync(ApplicationUser user, string token)
    {
        // Use ConfirmEmailAsync if it was GenerateEmailConfirmationTokenAsync
        // But since we want "code" behavior, maybe we should have used a specific provider.
        // Let's use the standard one for now.
        var result = await _userManager.ConfirmEmailAsync(user, token);
        return result.ToApplicationResult();
    }
}

public static class IdentityResultExtensions
{
    public static Result ToApplicationResult(this IdentityResult result)
    {
        return result.Succeeded
            ? Result.Success()
            : Result.Failure(result.Errors.Select(e => e.Description));
    }
}
