using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Shared.Interfaces.Services;
using Domain.Constants;
using Domain.Entities;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record RegisterCommand : IRequest<RegisterResponse>
{
    public string Email { get; init; } = string.Empty;
    public string Password { get; init; } = string.Empty;
    public string FirstName { get; init; } = string.Empty;
    public string LastName { get; init; } = string.Empty;
    public string? PhoneNumber { get; init; }
    public string? Address { get; init; }
    public string? City { get; init; }
    public string? Country { get; init; }
    public string? Bio { get; init; }
}

public record RegisterResponse(bool Success, string Message, TokenData? Token, UserDto? User);

public class RegisterCommandValidator : AbstractValidator<RegisterCommand>
{
    public RegisterCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Invalid email format.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(6).WithMessage("Password must be at least 6 characters.");

        RuleFor(x => x.FirstName).NotEmpty().WithMessage("First name is required.");
        RuleFor(x => x.LastName).NotEmpty().WithMessage("Last name is required.");
    }
}

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, RegisterResponse>
{
    private readonly IIdentityService _identityService;
    private readonly ITokenService _tokenService;
    private readonly IEmailSender _emailSender;
    private readonly IApplicationDbContext _context;

    public RegisterCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        IEmailSender emailSender,
        IApplicationDbContext context)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _emailSender = emailSender;
        _context = context;
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

        // All new users automatically get the "User" role — no Owner/Renter distinction
        await _identityService.AddToRoleAsync(user, Roles.User);

        var roles = await _identityService.GetUserRolesAsync(user);

        var tokenData = await _tokenService.GenerateTokensAsync(user.Id);

        var userDto = new UserDto(
            user.Id,
            user.Email!,
            user.FirstName,
            user.LastName,
            user.FullName,
            user.ProfilePictureUrl,
            roles.FirstOrDefault() ?? Roles.User,
            user.IsVerified,
            user.EmailConfirmed,
            user.Rating,
            roles,
            new List<string>(),
            user.Address,
            user.City,
            user.Country,
            user.Bio,
            user.PhoneNumber,
            user.CreatedAt
        );

        // Send confirmation email
        try
        {
            var token = await _identityService.GenerateEmailConfirmationTokenAsync(user);
            var body = Application.Shared.Utilities.EmailTemplates.GetEmailConfirmationTemplate(token);
            await _emailSender.SendEmailAsync(user.Email!, "Confirm Your Email - Rently", body);
        }
        catch (Exception)
        {
            // Log error but don't fail registration
        }

        return new RegisterResponse(true, "Registration successful.", tokenData, userDto);
    }
}
