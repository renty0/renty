using Application.Common.Interfaces;
using MediatR;

namespace Application.Web.Account;

public record DeleteUserCommand : IRequest<DeleteUserResponse>;

public record DeleteUserResponse(
    bool Success,
    string? Message
);

public class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand, DeleteUserResponse>
{
    private readonly IUser _currentUser;
    private readonly IIdentityService _identityService;

    public DeleteUserCommandHandler(IUser currentUser, IIdentityService identityService)
    {
        _currentUser = currentUser;
        _identityService = identityService;
    }

    public async Task<DeleteUserResponse> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new DeleteUserResponse(false, "User not authenticated.");
        }

        var user = await _identityService.GetUserByIdAsync(_currentUser.Id.Value);
        if (user == null)
        {
            return new DeleteUserResponse(false, "User not found.");
        }

        var result = await _identityService.DeleteUserAsync(user);
        if (!result.Succeeded)
        {
            return new DeleteUserResponse(false, string.Join(", ", result.Errors));
        }

        return new DeleteUserResponse(true, "Account deleted successfully.");
    }
}
