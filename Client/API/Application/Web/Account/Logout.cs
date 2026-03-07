using Application.Common.Interfaces;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record LogoutCommand(string RefreshToken) : IRequest<LogoutResponse>;

public record LogoutResponse(bool Success, string? Message);

public class LogoutCommandValidator : AbstractValidator<LogoutCommand>
{
    public LogoutCommandValidator()
    {
        RuleFor(x => x.RefreshToken)
            .NotEmpty().WithMessage("Refresh token is required.");
    }
}

public class LogoutCommandHandler : IRequestHandler<LogoutCommand, LogoutResponse>
{
    private readonly ITokenService _tokenService;

    public LogoutCommandHandler(ITokenService tokenService)
    {
        _tokenService = tokenService;
    }

    public async Task<LogoutResponse> Handle(LogoutCommand request, CancellationToken cancellationToken)
    {
        var refreshToken = await _tokenService.GetRefreshTokenAsync(request.RefreshToken);
        if (refreshToken == null)
        {
            return new LogoutResponse(false, "Invalid refresh token.");
        }

        if (!refreshToken.IsActive)
        {
            return new LogoutResponse(true, "Already logged out.");
        }

        await _tokenService.RevokeRefreshTokenAsync(refreshToken, "Logged out by user");

        return new LogoutResponse(true, "Logged out successfully.");
    }
}
