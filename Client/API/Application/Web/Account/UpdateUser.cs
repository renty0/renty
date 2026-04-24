using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Web.Account;

public record UpdateUserCommand : IRequest<UpdateUserResponse>
{
    public string? FirstName { get; init; }
    public string? LastName { get; init; }
    public string? PhoneNumber { get; init; }
    public string? Address { get; init; }
    public string? City { get; init; }
    public string? Country { get; init; }
    public string? Bio { get; init; }
    public string? ProfilePictureUrl { get; init; }
}

public class UpdateUserCommandValidator : AbstractValidator<UpdateUserCommand>
{
    public UpdateUserCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.FirstName))
            .WithMessage("First name must not exceed 100 characters.");

        RuleFor(x => x.LastName)
            .MaximumLength(100).When(x => !string.IsNullOrEmpty(x.LastName))
            .WithMessage("Last name must not exceed 100 characters.");

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^01[0125]\d{8}$")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber))
            .WithMessage("Invalid Egyptian phone number format (e.g., 01xxxxxxxxx).");

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

public record UpdateUserResponse(
    bool Success,
    string? Message,
    UserDto? User
);

public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, UpdateUserResponse>
{
    private readonly IUser _currentUser;
    private readonly IIdentityService _identityService;
    private readonly IApplicationDbContext _context;

    public UpdateUserCommandHandler(IUser currentUser, IIdentityService identityService, IApplicationDbContext context)
    {
        _currentUser = currentUser;
        _identityService = identityService;
        _context = context;
    }

    public async Task<UpdateUserResponse> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new UpdateUserResponse(false, "User not authenticated.", null);
        }

        var user = await _identityService.GetUserByIdAsync(_currentUser.Id.Value);
        if (user == null)
        {
            return new UpdateUserResponse(false, "User not found.", null);
        }

        if (request.FirstName != null) user.FirstName = request.FirstName;
        if (request.LastName != null) user.LastName = request.LastName;
        if (request.PhoneNumber != null) user.PhoneNumber = request.PhoneNumber;
        if (request.Address != null) user.Address = request.Address;
        if (request.City != null) user.City = request.City;
        if (request.Country != null) user.Country = request.Country;
        if (request.Bio != null) user.Bio = request.Bio;
        if (request.ProfilePictureUrl != null) user.ProfilePictureUrl = request.ProfilePictureUrl;

        var result = await _identityService.UpdateUserAsync(user);
        if (!result.Succeeded)
        {
            return new UpdateUserResponse(false, string.Join(", ", result.Errors), null);
        }

        var roles = await _identityService.GetUserRolesAsync(user);

        // Fetch granular permissions
        var userRoles = await _identityService.GetUserRolesAsync(user);
        var permissions = await _context.RolePermissions
                .Where(rp => userRoles.Contains(rp.RoleName))
                .Select(rp => rp.PermissionValue)
                .Distinct()
                .ToListAsync(cancellationToken);

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
            roles,
            permissions,
            user.Address,
            user.City,
            user.Country,
            user.Bio,
            user.PhoneNumber,
            user.CreatedAt
        );

        return new UpdateUserResponse(true, "Profile updated successfully.", userDto);
    }
}
