namespace Application.Web.Account;

public record UserDto(
    long Id,
    string Email,
    string FirstName,
    string LastName,
    string FullName,
    string? ProfilePictureUrl,
    string UserType,
    bool IsVerified,
    bool IsEmailConfirmed,
    double Rating,
    IList<string> Roles,
    string? Address = null,
    string? City = null,
    string? Country = null,
    string? Bio = null,
    string? PhoneNumber = null,
    DateTimeOffset CreatedAt = default
);

