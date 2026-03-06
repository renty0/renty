using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Application.Shared.Interfaces.Services;
using Application.Shared.Utilities;

namespace Application.Web.Account;

public record ForgotPasswordCommand(string Email) : IRequest<Result>;

public class ForgotPasswordCommandHandler : IRequestHandler<ForgotPasswordCommand, Result>
{
    private readonly IIdentityService _identityService;
    private readonly IEmailSender _emailSender;

    public ForgotPasswordCommandHandler(IIdentityService identityService, IEmailSender emailSender)
    {
        _identityService = identityService;
        _emailSender = emailSender;
    }

    public async Task<Result> Handle(ForgotPasswordCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        
        if (user == null)
        {
            return Result.Failure(new[] { "The email address is not registered." });
        }

        // Normally we would require email to be confirmed before password reset
        if (!user.EmailConfirmed)
        {
            // Optionally could send a message to confirm email instead
            return Result.Success(); 
        }

        var token = await _identityService.GeneratePasswordResetTokenAsync(user);
        var body = EmailTemplates.GetPasswordResetTemplate(token);
        
        await _emailSender.SendEmailAsync(user.Email!, "Reset Your Password - Rently", body);

        return Result.Success();
    }
}
