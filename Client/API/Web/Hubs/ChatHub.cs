using Application.Common.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Web.Hubs;

/// <summary>
/// Real-time chat hub at /hubs/chat
///
/// Client JS (example):
///   const conn = new signalR.HubConnectionBuilder()
///       .withUrl("/hubs/chat", { accessTokenFactory: () => token })
///       .withAutomaticReconnect()
///       .build();
///
///   await conn.start();
///   await conn.invoke("JoinChat", chatId);          // join room
///   conn.on("ReceiveMessage", (msg) => { ... });    // listen for messages
///   conn.on("UserTyping",  (userId) => { ... });    // typing indicator
/// </summary>
[Authorize]
public class ChatHub : Hub
{
    private readonly IApplicationDbContext _context;

    public ChatHub(IApplicationDbContext context) => _context = context;

    private long? CurrentUserId =>
        long.TryParse(Context.UserIdentifier, out var uid) ? uid : null;

    // ── Join / Leave ──────────────────────────────────────────────────────────

    /// <summary>Subscribe to a chat room's real-time updates.</summary>
    public async Task JoinChat(Guid chatId)
    {
        var uid = CurrentUserId;
        if (uid == null) { await Clients.Caller.SendAsync("Error", "Unauthorized."); return; }

        var chat = await _context.Chats.FirstOrDefaultAsync(c => c.Id == chatId);
        if (chat == null || (chat.User1Id != uid.Value && chat.User2Id != uid.Value))
        {
            await Clients.Caller.SendAsync("Error", "Forbidden or chat not found.");
            return;
        }

        await Groups.AddToGroupAsync(Context.ConnectionId, chatId.ToString());
        await Clients.Caller.SendAsync("Joined", chatId);
    }

    /// <summary>Unsubscribe from a chat room.</summary>
    public async Task LeaveChat(Guid chatId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, chatId.ToString());
        await Clients.Caller.SendAsync("Left", chatId);
    }

    // ── Typing Indicator ──────────────────────────────────────────────────────

    /// <summary>Broadcast "user is typing" to the other participant(s).</summary>
    public async Task TypingIndicator(Guid chatId)
    {
        var uid = CurrentUserId;
        if (uid == null) return;

        await Clients
            .OthersInGroup(chatId.ToString())
            .SendAsync("UserTyping", uid.Value);
    }
}
