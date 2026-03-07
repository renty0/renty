using System.Threading.Tasks;

namespace Application.Shared.Interfaces.Services;

public interface IEmailSender
{
    Task SendEmailAsync(string to, string subject, string htmlBody);
}
