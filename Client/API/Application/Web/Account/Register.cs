using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Application.Shared.Interfaces.Services;

namespace Application.Web.Account;

public record RegisterCommand(
    string Email,
    string Password,
    string ConfirmPassword,
    string FirstName,
    string LastName,
    string? PhoneNumber,
    UserType UserType = UserType.Renter,
    string? Address = null,
    string? City = null,
    string? Country = null,
    string? Bio = null
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
            .Matches(@"^01[0125]\d{8}$")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber))
            .WithMessage("Invalid Egyptian phone number format (e.g., 01xxxxxxxxx).");

        RuleFor(x => x.UserType)
            .IsInEnum().WithMessage("Invalid user type.");

        RuleFor(x => x.Address)
            .MaximumLength(500).When(x => !string.IsNullOrEmpty(x.Address))
            .WithMessage("Address must not exceed 500 characters.");

        RuleFor(x => x.City)
            .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.City))
            .WithMessage("City must not exceed 100 characters.");

        RuleFor(x => x.Country)
            .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.Country))
            .WithMessage("Country must not exceed 100 characters.");

        RuleFor(x => x.Bio)
            .MaximumLength(1000).When(x => !string.IsNullOrEmpty(x.Bio))
            .WithMessage("Bio must not exceed 1000 characters.");
    }
}

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, RegisterResponse>
{
    private readonly IIdentityService _identityService;
    private readonly ITokenService _tokenService;
    private readonly IEmailSender _emailSender;

    public RegisterCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        IEmailSender emailSender)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _emailSender = emailSender;
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
            UserType = request.UserType,
            Address = request.Address,
            City = request.City,
            Country = request.Country,
            Bio = request.Bio,
            IsActive = true,
            IsVerified = false,
            CreatedAt = DateTimeOffset.UtcNow
        };

        var createResult = await _identityService.CreateUserAsync(user, request.Password);
        if (!createResult.Succeeded)
        {
            return new RegisterResponse(false, string.Join(", ", createResult.Errors), null, null);
        }

        // Assign role based on user type
        var roleName = request.UserType switch
        {
            UserType.Owner => "Owner",
            UserType.Renter => "Renter",
            UserType.Both => "Owner", // Both gets Owner role (can do everything)
            _ => "Renter"
        };

        await _identityService.AddToRoleAsync(user, roleName);

        // If user type is Both, also add Renter role
        if (request.UserType == UserType.Both)
        {
            await _identityService.AddToRoleAsync(user, "Renter");
        }

        var roles = await _identityService.GetUserRolesAsync(user);

        var tokenData = await _tokenService.GenerateTokensAsync(user.Id);

        var userDto = new UserDto(
            user.Id,
            user.Email!,
            user.FirstName,
            user.LastName,
            user.FullName,
            user.ProfilePictureUrl,
            user.UserType.ToString(),
            user.IsVerified,
            user.EmailConfirmed,
            user.Rating,
            roles
        );

        // Send confirmation email
        try
        {
            var token = await _identityService.GenerateEmailConfirmationTokenAsync(user);
            var body = Application.Shared.Utilities.EmailTemplates.GetEmailConfirmationTemplate(token);
            await _emailSender.SendEmailAsync(user.Email!, "Confirm Your Email - Rently", body);
        }
        catch (Exception ex)
        {
            // Log error but don't fail registration
            // Maybe we should have a logger here
        }

        return new RegisterResponse(true, "Registration successful.", tokenData, userDto);
    }
}
