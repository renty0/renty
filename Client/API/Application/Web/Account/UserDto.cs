namespace Application.Web.Account;

public record UserDto(
    long Id,
    string Email,
    string FirstName,
    string LastName,
    string FullName,
    string? ProfilePictureUrl,
    string Role,
    bool IsVerified,
    bool IsEmailConfirmed,
    double Rating,
    IList<string> Roles,
    IList<string> Permissions,
    string? Address = null,
    string? City = null,
    string? Country = null,
    string? Bio = null,
    string? PhoneNumber = null,
    DateTimeOffset CreatedAt = default
);

