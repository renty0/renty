using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record RegisterCommand(
    string Email,
    string Password,
    string ConfirmPassword,
    string FirstName,
    string LastName,
    string? PhoneNumber
) : IRequest<RegisterResponse>;

public record RegisterResponse(
    bool Success,
    string? Message,
    TokenData? Token,
    UserDto? User
);

public class RegisterCommandValidator : AbstractValidator<RegisterCommand>
{
    public RegisterCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Invalid email format.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(6).WithMessage("Password must be at least 6 characters.")
            .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]").WithMessage("Password must contain at least one digit.");

        RuleFor(x => x.ConfirmPassword)
            .NotEmpty().WithMessage("Confirm password is required.")
            .Equal(x => x.Password).WithMessage("Passwords do not match.");

        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("First name is required.")
            .MaximumLength(100).WithMessage("First name must not exceed 100 characters.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Last name is required.")
            .MaximumLength(100).WithMessage("Last name must not exceed 100 characters.");

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^\+?[1-9]\d{1,14}$")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber))
            .WithMessage("Invalid phone number format.");
    }
}

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, RegisterResponse>
{
    private readonly IIdentityService _identityService;
    private readonly ITokenService _tokenService;
    private readonly ITokenGenerator _tokenGenerator;

    public RegisterCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        ITokenGenerator tokenGenerator)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _tokenGenerator = tokenGenerator;
    }

    public async Task<RegisterResponse> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var existingUser = await _identityService.GetUserByEmailAsync(request.Email);
        if (existingUser != null)
        {
            return new RegisterResponse(false, "Email is already registered.", null, null);
        }

        var user = new ApplicationUser
        {
            Email = request.Email,
            UserName = request.Email,
            FirstName = request.FirstName,
            LastName = request.LastName,
            PhoneNumber = request.PhoneNumber,
            IsActive = true,
            CreatedAt = DateTimeOffset.UtcNow
        };

        var createResult = await _identityService.CreateUserAsync(user, request.Password);
        if (!createResult.Succeeded)
        {
            return new RegisterResponse(false, string.Join(", ", createResult.Errors), null, null);
        }

        await _identityService.AddToRoleAsync(user, "User");

        var roles = await _identityService.GetUserRolesAsync(user);
        var accessToken = _tokenGenerator.GenerateAccessToken(user, roles);
        var refreshToken = await _tokenService.CreateRefreshTokenAsync(user.Id);

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
            user.ProfilePictureUrl,
            roles
        );

        return new RegisterResponse(true, "Registration successful.", tokenData, userDto);
    }
}
