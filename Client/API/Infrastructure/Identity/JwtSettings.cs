namespace Infrastructure.Identity;

public class JwtSettings
{
    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int TokenExpMinutes { get; set; } = 1440; // 24 hours
    public int RefreshTokenExpMinutes { get; set; } = 1440; // 24 hours
}
