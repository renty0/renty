namespace Application.Common.Interfaces;

public record NotificationPayload(
    long UserId,
    string Title,
    string Message,
    string Type,        // chat | rental | item | system | support
    string? ActionUrl
);

public interface INotificationSender
{
    Task SendToUserAsync(long userId, string title, string message, string type, string? actionUrl = null, CancellationToken ct = default);
    Task SendToUsersAsync(IEnumerable<long> userIds, string title, string message, string type, string? actionUrl = null, CancellationToken ct = default);
}
