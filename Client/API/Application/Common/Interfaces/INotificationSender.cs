namespace Application.Common.Interfaces;

public record NotificationPayload(
    long UserId,
    string Title,
    string Message,
    string Type,        // chat | rental | item | system | support
    string? ActionUrl,
    string? TitleAr = null,
    string? MessageAr = null
);

public interface INotificationSender
{
    Task SendToUserAsync(long userId, string title, string message, string type, string? actionUrl = null, CancellationToken ct = default,
        string? titleAr = null, string? messageAr = null);
    Task SendToUsersAsync(IEnumerable<long> userIds, string title, string message, string type, string? actionUrl = null, CancellationToken ct = default,
        string? titleAr = null, string? messageAr = null);
    Task SendToGroupAsync(string groupName, string method, object? payload = null, CancellationToken ct = default);
}
