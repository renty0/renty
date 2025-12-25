using System.Security.Claims;
using Domain.Entities;

namespace Application.Common.Interfaces;

public interface ITokenGenerator
{
    string GenerateAccessToken(ApplicationUser user, IList<string> roles);
    string GenerateRefreshToken();
    ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
    int TokenExpMinutes { get; }
}
