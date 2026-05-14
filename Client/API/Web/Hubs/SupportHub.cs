using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Web.Hubs;

/// <summary>
/// Real-time support chat hub at /hubs/support
/// Separate from the user-to-user chat hub — exclusively for
/// support ticket live conversations between users and staff.
/// </summary>
[Authorize]
public class SupportHub : Hub
{
    private readonly IApplicationDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;

    public SupportHub(IApplicationDbContext context, UserManager<ApplicationUser> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    private long? CurrentUserId =>
        long.TryParse(Context.UserIdentifier, out var uid) ? uid : null;

    // ── Join / Leave ──────────────────────────────────────────────────────────

    /// <summary>Join the real-time room for a specific support ticket.</summary>
    public async Task JoinTicket(string ticketId)
    {
        var uid = CurrentUserId;
        if (uid == null) { await Clients.Caller.SendAsync("Error", "Unauthorized."); return; }

        if (!Guid.TryParse(ticketId, out var ticketGuid))
        {
            await Clients.Caller.SendAsync("Error", "Invalid ticket ID.");
            return;
        }

        var ticket = await _context.SupportTickets.FirstOrDefaultAsync(t => t.Id == ticketGuid);
        if (ticket == null) { await Clients.Caller.SendAsync("Error", "Ticket not found."); return; }

        // Check permission: ticket owner OR support staff
        var user = await _userManager.FindByIdAsync(uid.Value.ToString());
        if (user == null) { await Clients.Caller.SendAsync("Error", "User not found."); return; }

        var roles = await _userManager.GetRolesAsync(user);
        bool isOwner = ticket.UserId == uid.Value;
        bool isStaff = roles.Any(r => r == "Support" || r == "Admin" || r == "SuperAdmin");

        if (!isOwner && !isStaff)
        {
            await Clients.Caller.SendAsync("Error", "Forbidden.");
            return;
        }

        var groupName = $"ticket_{ticketId}";
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

        // Notify others if a support agent joined
        if (isStaff && !isOwner)
        {
            var agentInfo = new { Id = uid.Value, Name = user.FullName, Role = "Support" };
            await Clients.OthersInGroup(groupName).SendAsync("AgentJoined", agentInfo);
        }

        await Clients.Caller.SendAsync("JoinedTicket", ticketId);
    }

    /// <summary>Leave the ticket room.</summary>
    public async Task LeaveTicket(string ticketId)
    {
        var groupName = $"ticket_{ticketId}";
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
        await Clients.OthersInGroup(groupName).SendAsync("AgentLeft", CurrentUserId);
    }

    // ── Typing Indicator ──────────────────────────────────────────────────────

    public async Task TypingIndicator(string ticketId, string senderName)
    {
        await Clients
            .OthersInGroup($"ticket_{ticketId}")
            .SendAsync("UserTyping", senderName);
    }

    // ── Static Broadcast Helper ───────────────────────────────────────────────

    /// <summary>
    /// Called from support endpoints after persisting a new message,
    /// to push it in real-time to all participants.
    /// </summary>
    public static async Task BroadcastMessage(
        IHubContext<SupportHub> hubContext,
        string ticketId,
        object message)
    {
        await hubContext.Clients
            .Group($"ticket_{ticketId}")
            .SendAsync("ReceiveSupportMessage", message);
    }
}
