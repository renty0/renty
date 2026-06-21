using Application.Features.Chats;
using Microsoft.AspNetCore.SignalR;
using Web.Hubs;

namespace Web.Services;

/// <summary>
/// Web-layer implementation of IChatNotifier.
/// Bridges the Application layer to SignalR without creating a circular dependency.
/// </summary>
public class ChatHubNotifier : IChatNotifier
{
    private readonly IHubContext<ChatHub> _hub;

    public ChatHubNotifier(IHubContext<ChatHub> hub) => _hub = hub;

    public async Task SendMessageAsync(Guid chatId, IEnumerable<string> userIds, object payload, CancellationToken ct)
    {
        await _hub.Clients
            .Users(userIds)
            .SendAsync("ReceiveMessage", payload, ct);
    }
}
