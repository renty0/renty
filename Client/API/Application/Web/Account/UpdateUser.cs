using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record UpdateUserCommand : IRequest<UpdateUserResponse>
{
    public string FirstName { get; init; } = string.Empty;
    public string LastName { get; init; } = string.Empty;
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
            .NotEmpty().WithMessage("First name is required.")
            .MaximumLength(100).WithMessage("First name must not exceed 100 characters.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Last name is required.")
            .MaximumLength(100).WithMessage("Last name must not exceed 100 characters.");

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

    public UpdateUserCommandHandler(IUser currentUser, IIdentityService identityService)
    {
        _currentUser = currentUser;
        _identityService = identityService;
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

        user.FirstName = request.FirstName;
        user.LastName = request.LastName;
        user.PhoneNumber = request.PhoneNumber;
        user.Address = request.Address;
        user.City = request.City;
        user.Country = request.Country;
        user.Bio = request.Bio;
        user.ProfilePictureUrl = request.ProfilePictureUrl;

        var result = await _identityService.UpdateUserAsync(user);
        if (!result.Succeeded)
        {
            return new UpdateUserResponse(false, string.Join(", ", result.Errors), null);
        }

        var roles = await _identityService.GetUserRolesAsync(user);

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
            user.Address,
            user.City,
            user.Country,
            user.Bio
        );

        return new UpdateUserResponse(true, "Profile updated successfully.", userDto);
    }
}
