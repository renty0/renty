using Application.Common.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Web.Hubs;

/// <summary>
/// Real-time notification hub at /hubs/notifications
/// Each authenticated user joins their own group "user_{userId}"
/// automatically on connection, so we can push notifications from
/// anywhere in the backend.
/// </summary>
[Authorize]
public class NotificationHub : Hub
{
    private long? CurrentUserId =>
        long.TryParse(Context.UserIdentifier, out var uid) ? uid : null;

    public override async Task OnConnectedAsync()
    {
        var uid = CurrentUserId;
        if (uid.HasValue)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{uid.Value}");
            
            if (Context.User?.IsInRole("Admin") == true || Context.User?.IsInRole("SuperAdmin") == true)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, "Admins");
            }
        }
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var uid = CurrentUserId;
        if (uid.HasValue)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user_{uid.Value}");
        }
        await base.OnDisconnectedAsync(exception);
    }
}
