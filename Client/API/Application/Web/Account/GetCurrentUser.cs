using Application.Common.Interfaces;
using Application.Common;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;


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
    private readonly IApplicationDbContext _context;

    public GetCurrentUserQueryHandler(IUser currentUser, IIdentityService identityService, IHttpContextAccessor httpContextAccessor, IApplicationDbContext context)
    {
        _currentUser = currentUser;
        _identityService = identityService;
        _httpContextAccessor = httpContextAccessor;
        _context = context;
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

        // Fetch granular permissions
        var userRoles = await _identityService.GetUserRolesAsync(user);
        var permissions = await _context.RolePermissions
                .Where(rp => userRoles.Contains(rp.RoleName))
                .Select(rp => rp.PermissionValue)
                .Distinct()
                .ToListAsync(cancellationToken);

        var idVerification = await _context.IdVerifications
                .Where(v => v.UserId == user.Id)
                .OrderByDescending(v => v.CreatedAt)
                .FirstOrDefaultAsync(cancellationToken);

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
            idVerification?.Status.ToString(),
            user.IdVerified
        );

        return new GetCurrentUserResponse(true, null, userDto);
    }
}
