using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Application.Shared.Interfaces.Services;
using Application.Shared.Utilities;

namespace Application.Web.Account;

public record SendEmailConfirmationCommand(string Email) : IRequest<Result>;

public class SendEmailConfirmationCommandHandler : IRequestHandler<SendEmailConfirmationCommand, Result>
{
    private readonly IIdentityService _identityService;
    private readonly IEmailSender _emailSender;

    public SendEmailConfirmationCommandHandler(IIdentityService identityService, IEmailSender emailSender)
    {
        _identityService = identityService;
        _emailSender = emailSender;
    }

    public async Task<Result> Handle(SendEmailConfirmationCommand request, CancellationToken cancellationToken)
    {
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        if (user == null)
        {
            return Result.Failure("User not found.");
        }

        var token = await _identityService.GenerateEmailConfirmationTokenAsync(user);
        var body = EmailTemplates.GetEmailConfirmationTemplate(token);
        
        await _emailSender.SendEmailAsync(user.Email!, "Confirm Your Email - Rently", body);

        return Result.Success();
    }
}
