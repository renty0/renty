namespace Application.Common.Models;

public record TokenData(
    string AccessToken,
    string RefreshToken,
    DateTimeOffset ExpiresAt
);
