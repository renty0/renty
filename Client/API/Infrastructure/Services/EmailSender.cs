using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Application.Shared.Interfaces.Services;

namespace Infrastructure.Services;

public class EmailSender : IEmailSender
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailSender> _logger;

    public EmailSender(IConfiguration configuration, ILogger<EmailSender> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendEmailAsync(string to, string subject, string htmlBody)
    {
        var emailConfig = _configuration.GetSection("EmailConfig");
        var host = emailConfig["Host"];
        var port = int.Parse(emailConfig["Port"]);
        var fromAddress = emailConfig["FromAddress"];
        var password = emailConfig["Password"];
        var enableSsl = bool.Parse(emailConfig["EnableSsl"]);

        try
        {
            using var client = new SmtpClient(host, port)
            {
                Credentials = new NetworkCredential(fromAddress, password),
                EnableSsl = enableSsl
            };

            var mailMessage = new MailMessage
            {
                From = new MailAddress(fromAddress, "Rently"),
                Subject = subject,
                Body = htmlBody,
                IsBodyHtml = true
            };

            mailMessage.To.Add(to);

            await client.SendMailAsync(mailMessage);
            _logger.LogInformation($"Email sent successfully to {to}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error sending email to {to}");
            // Don't rethrow — email failure should not break registration or other flows
        }
    }
}
