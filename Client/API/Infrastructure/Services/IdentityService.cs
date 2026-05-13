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
        return await _userManager.GenerateTwoFactorTokenAsync(user, "Email");
    }

    public async Task<Result> ConfirmEmailAsync(ApplicationUser user, string token)
    {
        var isValid = await _userManager.VerifyTwoFactorTokenAsync(user, "Email", token);
        if (isValid)
        {
            user.EmailConfirmed = true;
            await _userManager.UpdateAsync(user);
            return Result.Success();
        }
        return Result.Failure("Invalid or expired verification code.");
    }

    public async Task<string> GeneratePasswordResetTokenAsync(ApplicationUser user)
    {
        return await _userManager.GenerateTwoFactorTokenAsync(user, "Email");
    }

    public async Task<Result> ResetPasswordAsync(ApplicationUser user, string token, string newPassword)
    {
        var isValid = await _userManager.VerifyTwoFactorTokenAsync(user, "Email", token);
        if (!isValid)
        {
            return Result.Failure("Invalid or expired reset code.");
        }

        var removeResult = await _userManager.RemovePasswordAsync(user);
        if (!removeResult.Succeeded)
        {
            return removeResult.ToApplicationResult();
        }

        var addResult = await _userManager.AddPasswordAsync(user, newPassword);
        return addResult.ToApplicationResult();
    }

    public async Task<bool> VerifyPasswordResetTokenAsync(ApplicationUser user, string token)
    {
        return await _userManager.VerifyTwoFactorTokenAsync(user, "Email", token);
    }
    
    public async Task<bool> IsLockedOutAsync(ApplicationUser user)
    {
        return await _userManager.IsLockedOutAsync(user);
    }

    public async Task IncrementAccessFailedCountAsync(ApplicationUser user)
    {
        await _userManager.AccessFailedAsync(user);
    }

    public async Task ResetAccessFailedCountAsync(ApplicationUser user)
    {
        await _userManager.ResetAccessFailedCountAsync(user);
    }

    public async Task<Result> DeleteUserAsync(ApplicationUser user)
    {
        var result = await _userManager.DeleteAsync(user);
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
