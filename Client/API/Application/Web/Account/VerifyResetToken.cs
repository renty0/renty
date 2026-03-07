using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;

namespace Application.Web.Account;

public record VerifyResetTokenCommand(string Email, string Token) : IRequest<Result>;

public class VerifyResetTokenCommandValidator : AbstractValidator<VerifyResetTokenCommand>
{
    public VerifyResetTokenCommandValidator()
    {
        RuleFor(v => v.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Email is not valid.");

        RuleFor(v => v.Token)
            .NotEmpty().WithMessage("Token is required.");
    }
}

public class VerifyResetTokenCommandHandler : IRequestHandler<VerifyResetTokenCommand, Result>
{
    private readonly IIdentityService _identityService;

    public VerifyResetTokenCommandHandler(IIdentityService identityService)
    {
        _identityService = identityService;
    }

    public async Task<Result> Handle(VerifyResetTokenCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        
        if (user == null)
        {
            return Result.Failure("Invalid token or email.");
        }

        var isValid = await _identityService.VerifyPasswordResetTokenAsync(user, request.Token);

        if (!isValid)
        {
            return Result.Failure("Invalid or expired reset code.");
        }

        return Result.Success();
    }
}
