using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Notifications;

public record NotificationDto(Guid Id, string Title, string Message, string Type, string? ActionUrl, bool IsRead, DateTime CreatedAt);

public record GetNotificationsQuery : IRequest<GetNotificationsResponse>;
public record GetNotificationsResponse(List<NotificationDto> Notifications, int UnreadCount);

public class GetNotificationsQueryHandler : IRequestHandler<GetNotificationsQuery, GetNotificationsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetNotificationsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetNotificationsResponse> Handle(GetNotificationsQuery request, CancellationToken ct)
    {
        var notifications = await _context.Notifications
            .Where(n => n.UserId == _currentUser.Id!.Value)
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new NotificationDto(n.Id, n.Title, n.Message, n.Type, n.ActionUrl, n.IsRead, n.CreatedAt))
            .ToListAsync(ct);

        return new GetNotificationsResponse(notifications, notifications.Count(n => !n.IsRead));
    }
}

public record MarkNotificationReadCommand(Guid NotificationId) : IRequest<MarkNotificationReadResponse>;
public record MarkNotificationReadResponse(bool Success, string? Error);

public class MarkNotificationReadCommandHandler : IRequestHandler<MarkNotificationReadCommand, MarkNotificationReadResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public MarkNotificationReadCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<MarkNotificationReadResponse> Handle(MarkNotificationReadCommand request, CancellationToken ct)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == request.NotificationId && n.UserId == _currentUser.Id!.Value, ct);

        if (notification == null) return new MarkNotificationReadResponse(false, "Notification not found.");

        notification.IsRead = true;
        await _context.SaveChangesAsync(ct);
        return new MarkNotificationReadResponse(true, null);
    }
}

public record MarkAllNotificationsReadCommand : IRequest<MarkAllNotificationsReadResponse>;
public record MarkAllNotificationsReadResponse(bool Success, int Updated);

public class MarkAllNotificationsReadCommandHandler : IRequestHandler<MarkAllNotificationsReadCommand, MarkAllNotificationsReadResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public MarkAllNotificationsReadCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<MarkAllNotificationsReadResponse> Handle(MarkAllNotificationsReadCommand request, CancellationToken ct)
    {
        var unread = await _context.Notifications
            .Where(n => n.UserId == _currentUser.Id!.Value && !n.IsRead)
            .ToListAsync(ct);

        foreach (var n in unread) n.IsRead = true;
        await _context.SaveChangesAsync(ct);
        return new MarkAllNotificationsReadResponse(true, unread.Count);
    }
}
