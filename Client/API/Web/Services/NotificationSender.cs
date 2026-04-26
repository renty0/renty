using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.AspNetCore.SignalR;
using Web.Hubs;

namespace Web.Services;

/// <summary>
/// Saves notifications to the DB and pushes them via SignalR in one call.
/// Registered as a scoped service in DI.
/// </summary>
public class NotificationSender : INotificationSender
{
    private readonly IApplicationDbContext _context;
    private readonly IHubContext<NotificationHub> _hub;

    public NotificationSender(IApplicationDbContext context, IHubContext<NotificationHub> hub)
    {
        _context = context;
        _hub = hub;
    }

    public async Task SendToUserAsync(long userId, string title, string message, string type, string? actionUrl = null, CancellationToken ct = default)
    {
        var notification = new Notification
        {
            UserId = userId,
            Title = title,
            Message = message,
            Type = type,
            ActionUrl = actionUrl,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };
        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync(ct);

        var payload = new
        {
            id = notification.Id,
            title,
            message,
            type,
            actionUrl,
            isRead = false,
            createdAt = notification.CreatedAt
        };

        await _hub.Clients.Group($"user_{userId}")
            .SendAsync("ReceiveNotification", payload, ct);
    }

    public async Task SendToUsersAsync(IEnumerable<long> userIds, string title, string message, string type, string? actionUrl = null, CancellationToken ct = default)
    {
        var ids = userIds.Distinct().ToList();
        if (ids.Count == 0) return;

        var now = DateTime.UtcNow;
        var notifications = ids.Select(uid => new Notification
        {
            UserId = uid,
            Title = title,
            Message = message,
            Type = type,
            ActionUrl = actionUrl,
            IsRead = false,
            CreatedAt = now
        }).ToList();

        _context.Notifications.AddRange(notifications);
        await _context.SaveChangesAsync(ct);

        var payload = new { title, message, type, actionUrl, isRead = false, createdAt = now };

        var tasks = ids.Select(uid =>
            _hub.Clients.Group($"user_{uid}").SendAsync("ReceiveNotification",
                new { id = notifications.First(n => n.UserId == uid).Id, title, message, type, actionUrl, isRead = false, createdAt = now },
                ct));

        await Task.WhenAll(tasks);
    }
}
