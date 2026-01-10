using Application.Common.Interfaces;
using Domain.Entities;
using Infrastructure.Data;
using Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.Identity;
using Application.Common.Models;

namespace Infrastructure.Services;

public class TokenService : ITokenService
{
    private readonly ApplicationDbContext _context;
    private readonly ITokenGenerator _tokenGenerator;
    private readonly JwtSettings _jwtSettings;
    private readonly UserManager<ApplicationUser> _userManager;

    public TokenService(
        ApplicationDbContext context,
        ITokenGenerator tokenGenerator,
        IOptions<JwtSettings> jwtSettings,
        UserManager<ApplicationUser> userManager)
    {
        _context = context;
        _tokenGenerator = tokenGenerator;
        _jwtSettings = jwtSettings.Value;
        _userManager = userManager;
    }

    public async Task<TokenData> GenerateTokensAsync(long userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) throw new KeyNotFoundException($"User with ID {userId} not found");

        var roles = await _userManager.GetRolesAsync(user);
        var accessToken = _tokenGenerator.GenerateAccessToken(user, roles);
        var refreshToken = await CreateRefreshTokenAsync(userId);

        return new TokenData(
            accessToken,
            DateTimeOffset.UtcNow.AddMinutes(_jwtSettings.TokenExpMinutes),
            refreshToken.Token,
            refreshToken.ExpiresAt
        );
    }

    public async Task<RefreshToken> CreateRefreshTokenAsync(long userId)
    {
        var token = _tokenGenerator.GenerateRefreshToken();
        var refreshToken = new RefreshToken
        {
            Token = token,
            UserId = userId,
            ExpiresAt = DateTimeOffset.UtcNow.AddMinutes(_jwtSettings.RefreshTokenExpMinutes),
            IsRevoked = false
        };

        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        return refreshToken;
    }

    public async Task<RefreshToken?> GetRefreshTokenAsync(string token)
    {
        return await _context.RefreshTokens
            .Include(r => r.User)
            .FirstOrDefaultAsync(r => r.Token == token);
    }

    public async Task RevokeRefreshTokenAsync(RefreshToken token, string? reason = null, string? replacedByToken = null)
    {
        token.IsRevoked = true;
        token.RevokedAt = DateTimeOffset.UtcNow;
        token.ReasonRevoked = reason;
        token.ReplacedByToken = replacedByToken;

        _context.RefreshTokens.Update(token);
        await _context.SaveChangesAsync();
    }

    public async Task RevokeAllUserRefreshTokensAsync(long userId, string? reason = null)
    {
        var tokens = await _context.RefreshTokens
            .Where(r => r.UserId == userId && !r.IsRevoked)
            .ToListAsync();

        foreach (var token in tokens)
        {
            token.IsRevoked = true;
            token.RevokedAt = DateTimeOffset.UtcNow;
            token.ReasonRevoked = reason;
        }

        await _context.SaveChangesAsync();
    }
}
