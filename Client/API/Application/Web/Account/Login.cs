using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record LoginCommand(string Email, string Password) : IRequest<LoginResponse>;

public record LoginResponse(
    bool Success,
    string? Message,
    TokenData? Token,
    UserDto? User
);

public record UserDto(
    long Id,
    string Email,
    string FirstName,
    string LastName,
    string FullName,
    string? ProfilePictureUrl,
    string UserType,
    bool IsVerified,
    double Rating,
    IList<string> Roles
);

public class LoginCommandValidator : AbstractValidator<LoginCommand>
{
    public LoginCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Invalid email format.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.");
    }
}

public class LoginCommandHandler : IRequestHandler<LoginCommand, LoginResponse>
{
    private readonly IIdentityService _identityService;
    private readonly ITokenService _tokenService;
    private readonly ITokenGenerator _tokenGenerator;

    public LoginCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        ITokenGenerator tokenGenerator)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _tokenGenerator = tokenGenerator;
    }

    public async Task<LoginResponse> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        if (user == null)
        {
            return new LoginResponse(false, "Invalid email or password.", null, null);
        }

        if (!user.IsActive)
        {
            return new LoginResponse(false, "Account is deactivated.", null, null);
        }

        var isValidPassword = await _identityService.ValidatePasswordAsync(user, request.Password);
        if (!isValidPassword)
        {
            return new LoginResponse(false, "Invalid email or password.", null, null);
        }

        var roles = await _identityService.GetUserRolesAsync(user);
        var accessToken = _tokenGenerator.GenerateAccessToken(user, roles);
        var refreshToken = await _tokenService.CreateRefreshTokenAsync(user.Id);

        await _identityService.UpdateLastLoginAsync(user);

        var tokenData = new TokenData(
            accessToken,
            refreshToken.Token,
            DateTimeOffset.UtcNow.AddMinutes(_tokenGenerator.TokenExpMinutes)
        );

        var userDto = new UserDto(
            user.Id,
            user.Email!,
            user.FirstName,
            user.LastName,
            user.FullName,
            user.ProfilePictureUrl,
            user.UserType.ToString(),
            user.IsVerified,
            user.Rating,
            roles
        );

        return new LoginResponse(true, "Login successful.", tokenData, userDto);
    }
}
