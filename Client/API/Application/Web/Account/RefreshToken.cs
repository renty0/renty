using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record RefreshTokenCommand(string AccessToken, string RefreshToken) : IRequest<RefreshTokenResponse>;

public record RefreshTokenResponse(
    bool Success,
    string? Message,
    TokenData? Token
);

public class RefreshTokenCommandValidator : AbstractValidator<RefreshTokenCommand>
{
    public RefreshTokenCommandValidator()
    {
        RuleFor(x => x.AccessToken)
            .NotEmpty().WithMessage("Access token is required.");

        RuleFor(x => x.RefreshToken)
            .NotEmpty().WithMessage("Refresh token is required.");
    }
}

public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, RefreshTokenResponse>
{
    private readonly IIdentityService _identityService;
    private readonly ITokenService _tokenService;
    private readonly ITokenGenerator _tokenGenerator;

    public RefreshTokenCommandHandler(
        IIdentityService identityService,
        ITokenService tokenService,
        ITokenGenerator tokenGenerator)
    {
        _identityService = identityService;
        _tokenService = tokenService;
        _tokenGenerator = tokenGenerator;
    }

    public async Task<RefreshTokenResponse> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        // Validate the expired access token
        var principal = _tokenGenerator.GetPrincipalFromExpiredToken(request.AccessToken);
        if (principal == null)
        {
            return new RefreshTokenResponse(false, "Invalid access token.", null);
        }

        var userIdClaim = principal.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
        if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out var userId))
        {
            return new RefreshTokenResponse(false, "Invalid access token.", null);
        }

        // Validate refresh token
        var storedRefreshToken = await _tokenService.GetRefreshTokenAsync(request.RefreshToken);
        if (storedRefreshToken == null)
        {
            return new RefreshTokenResponse(false, "Invalid refresh token.", null);
        }

        if (storedRefreshToken.UserId != userId)
        {
            return new RefreshTokenResponse(false, "Token mismatch.", null);
        }

        if (!storedRefreshToken.IsActive)
        {
            return new RefreshTokenResponse(false, "Refresh token has expired or been revoked.", null);
        }

        // Get user and generate new tokens
        var user = await _identityService.GetUserByIdAsync(userId);
        if (user == null || !user.IsActive)
        {
            return new RefreshTokenResponse(false, "User not found or inactive.", null);
        }

        var tokenData = await _tokenService.GenerateTokensAsync(user.Id);

        // Revoke the old refresh token
        await _tokenService.RevokeRefreshTokenAsync(
            storedRefreshToken,
            "Replaced by new token",
            tokenData.RefreshToken
        );

        return new RefreshTokenResponse(true, "Token refreshed successfully.", tokenData);
    }
}
