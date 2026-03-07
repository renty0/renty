using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Shared.Interfaces.Services;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;


namespace Application.Web.Account;

public record LoginCommand(string Email, string Password) : IRequest<LoginResponse>;

public record LoginResponse(
    bool Success,
    string? Message,
    TokenData? Token,
    UserDto? User
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
    private readonly IEmailSender _emailSender;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public LoginCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        IEmailSender emailSender,
        IHttpContextAccessor httpContextAccessor)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _emailSender = emailSender;
        _httpContextAccessor = httpContextAccessor;
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

        if (!user.EmailConfirmed)
        {
            try
            {
                var token = await _identityService.GenerateEmailConfirmationTokenAsync(user);
                var body = Application.Shared.Utilities.EmailTemplates.GetEmailConfirmationTemplate(token);
                await _emailSender.SendEmailAsync(user.Email!, "Confirm Your Email - Rently", body);
            }
            catch (Exception)
            {
                // In a real app, we should log this
            }
            
            return new LoginResponse(false, "EmailNotConfirmed", null, null);
        }

        var isValidPassword = await _identityService.ValidatePasswordAsync(user, request.Password);
        if (!isValidPassword)
        {
            return new LoginResponse(false, "Invalid email or password.", null, null);
        }

        var roles = await _identityService.GetUserRolesAsync(user);
        
        await _identityService.UpdateLastLoginAsync(user);

        var tokenData = await _tokenService.GenerateTokensAsync(user.Id);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : null;

        var userDto = new UserDto(
            user.Id,
            user.Email!,
            user.FirstName,
            user.LastName,
            user.FullName,
            !string.IsNullOrEmpty(user.ProfilePictureUrl) && !string.IsNullOrEmpty(baseUrl) 
                ? $"{baseUrl.TrimEnd('/')}/{user.ProfilePictureUrl.TrimStart('/')}" 
                : user.ProfilePictureUrl,
            user.UserType.ToString(),
            user.IsVerified,
            user.EmailConfirmed,
            user.Rating,

            roles,
            user.Address,
            user.City,
            user.Country,
            user.Bio,
            user.PhoneNumber
        );

        return new LoginResponse(true, "Login successful.", tokenData, userDto);
    }
}
