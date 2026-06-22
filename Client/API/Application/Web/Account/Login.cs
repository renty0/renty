using Application.Common.Interfaces;
using Application.Common;
using Application.Common.Models;
using Application.Shared.Interfaces.Services;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;


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
    private readonly IApplicationDbContext _context;

    public LoginCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        IEmailSender emailSender,
        IHttpContextAccessor httpContextAccessor,
        IApplicationDbContext context)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _emailSender = emailSender;
        _httpContextAccessor = httpContextAccessor;
        _context = context;
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
            return new LoginResponse(false, "Account is suspended. Please contact support.", null, null);
        }

        if (await _identityService.IsLockedOutAsync(user))
        {
            return new LoginResponse(false, "Account locked due to multiple failed attempts. Please try again later.", null, null);
        }

        var isValidPassword = await _identityService.ValidatePasswordAsync(user, request.Password);
        if (!isValidPassword)
        {
            await _identityService.IncrementAccessFailedCountAsync(user);
            
            // Re-check lockout status after incrementing
            if (await _identityService.IsLockedOutAsync(user))
            {
                return new LoginResponse(false, "Account locked due to multiple failed attempts. Please try again later.", null, null);
            }

            return new LoginResponse(false, "Invalid email or password.", null, null);
        }

        // Reset failed attempts on successful password validation
        await _identityService.ResetAccessFailedCountAsync(user);

        // Note: We now allow login even if email is not confirmed, 
        // but we will block rentals later in the CreateRental command.
        
        var roles = await _identityService.GetUserRolesAsync(user);
        
        // Fetch permissions for these roles
        var permissions = await _context.RolePermissions
            .Where(rp => roles.Contains(rp.RoleName))
            .Select(rp => rp.PermissionValue)
            .Distinct()
            .ToListAsync(cancellationToken);
        
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
            user.ProfilePictureUrl.ToAbsoluteUrl(baseUrl),
            roles.FirstOrDefault() ?? Domain.Constants.Roles.User,
            user.IsVerified,
            user.EmailConfirmed,
            user.Rating,
            roles,
            permissions,
            user.Address,
            user.City,
            user.Country,
            user.Bio,
            user.PhoneNumber,
            user.CreatedAt,
            null,
            user.IdVerified
        );

        return new LoginResponse(true, "Login successful.", tokenData, userDto);
    }
}
