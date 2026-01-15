using Application.Common.Interfaces;
using MediatR;

namespace Application.Web.Account;

public record GetCurrentUserQuery : IRequest<GetCurrentUserResponse>;

public record GetCurrentUserResponse(
    bool Success,
    string? Message,
    UserDto? User
);

public class GetCurrentUserQueryHandler : IRequestHandler<GetCurrentUserQuery, GetCurrentUserResponse>
{
    private readonly IUser _currentUser;
    private readonly IIdentityService _identityService;

    public GetCurrentUserQueryHandler(IUser currentUser, IIdentityService identityService)
    {
        _currentUser = currentUser;
        _identityService = identityService;
    }

    public async Task<GetCurrentUserResponse> Handle(GetCurrentUserQuery request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new GetCurrentUserResponse(false, "User not authenticated.", null);
        }

        var user = await _identityService.GetUserByIdAsync(_currentUser.Id.Value);
        if (user == null)
        {
            return new GetCurrentUserResponse(false, "User not found.", null);
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

        return new GetCurrentUserResponse(true, null, userDto);
    }
}
