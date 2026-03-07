using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;

namespace Application.Web.Account;

public record ConfirmEmailCommand(string Email, string Code) : IRequest<Result>;

public class ConfirmEmailCommandHandler : IRequestHandler<ConfirmEmailCommand, Result>
{
    private readonly IIdentityService _identityService;

    public ConfirmEmailCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<Result> Handle(ConfirmEmailCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        if (user == null)
        {
            return Result.Failure("User not found.");
        }

        return await _identityService.ConfirmEmailAsync(user, request.Code);
    }
}
