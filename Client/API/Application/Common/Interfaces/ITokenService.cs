using Domain.Entities;

namespace Application.Common.Interfaces;

public interface ITokenService
{
    Task<Models.TokenData> GenerateTokensAsync(long userId);
    Task<RefreshToken> CreateRefreshTokenAsync(long userId);
    Task<RefreshToken?> GetRefreshTokenAsync(string token);
    Task RevokeRefreshTokenAsync(RefreshToken token, string? reason = null, string? replacedByToken = null);
    Task RevokeAllUserRefreshTokensAsync(long userId, string? reason = null);
}
