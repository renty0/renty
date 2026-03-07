using Application.Common.Interfaces;
using MediatR;
using Microsoft.AspNetCore.Http;


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
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetCurrentUserQueryHandler(IUser currentUser, IIdentityService identityService, IHttpContextAccessor httpContextAccessor)
    {
        _currentUser = currentUser;
        _identityService = identityService;
        _httpContextAccessor = httpContextAccessor;
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
            user.PhoneNumber,
            user.CreatedAt
        );

        return new GetCurrentUserResponse(true, null, userDto);
    }
}
