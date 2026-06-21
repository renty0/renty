using Application.Features.Support;
using MediatR;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using Web.Responses;

namespace Web.Endpoints;

public static class SupportEndpoints
{
    public static void MapSupportEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/support").WithTags("Support").RequireAuthorization();

        // POST /support/tickets
        g.MapPost("/tickets", async (CreateTicketCommand cmd, ISender sender, Microsoft.AspNetCore.SignalR.IHubContext<Web.Hubs.SupportHub> hubContext) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            // TicketId is Guid? — use .Value (it's non-null on success)
            if (r.AutoReplyMessage != null)
            {
                var liveMessage = new {
                    Id = r.AutoReplyMessage.Id.ToString(),
                    TicketId = r.TicketId!.Value.ToString(),
                    SenderId = r.AutoReplyMessage.SenderId,
                    SenderName = "Support Team",
                    SenderRole = "Support",
                    Message = r.AutoReplyMessage.Message,
                    MediaUrl = r.AutoReplyMessage.MediaUrl,
                    MessageType = r.AutoReplyMessage.MessageType,
                    CreatedAt = r.AutoReplyMessage.CreatedAt
                };
                
                // Fire and forget broadcast, so we don't delay the HTTP response
                _ = Web.Hubs.SupportHub.BroadcastMessage(hubContext, r.TicketId!.Value.ToString(), liveMessage);
            }

            return Api.Created(new SupportCreateTicketData(r.TicketId!.Value, r.Status, r.AutoReplyMessage));
        })
        .WithName("CreateSupportTicket")
        .Produces<ApiResponse<SupportCreateTicketData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        // GET /support/tickets
        g.MapGet("/tickets", async (ClaimsPrincipal cp, ISender sender) =>
        {
            var isSupport = cp.IsInRole(Roles.Support) || cp.IsInRole(Roles.Admin);
            var r = await sender.Send(new GetTicketsQuery(isSupport));
            return Api.Ok(r);
        })
        .WithName("GetSupportTickets")
        .Produces<ApiResponse<GetTicketsResponse>>(StatusCodes.Status200OK);

        // GET /support/tickets/:id
        g.MapGet("/tickets/{id:guid}", async (Guid id, ClaimsPrincipal cp, ISender sender) =>
        {
            var isSupport = cp.IsInRole(Roles.Support) || cp.IsInRole(Roles.Admin);
            var r = await sender.Send(new GetTicketQuery(id, isSupport));
            if (!r.Found) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r);
        })
        .WithName("GetSupportTicketDetails")
        .Produces<ApiResponse<GetTicketResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        // POST /support/tickets/:id/messages
        g.MapPost("/tickets/{id:guid}/messages", async (Guid id, PostSupportMessageCommand cmd, ClaimsPrincipal cp, ISender sender, Microsoft.AspNetCore.SignalR.IHubContext<Web.Hubs.SupportHub> hubContext) =>
        {
            var isSupport = cp.IsInRole(Roles.Support) || cp.IsInRole(Roles.Admin);
            var r = await sender.Send(cmd with { TicketId = id, IsSupportAgent = isSupport });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            // MessageId and CreatedAt are Guid?/DateTime? — use .Value on success
            
            // Broadcast the message to the SignalR Hub
            var senderId = long.Parse(cp.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");
            var senderName = cp.FindFirstValue("FullName") ?? cp.FindFirstValue(ClaimTypes.Name) ?? "User";
            
            var liveMessage = new {
                Id = r.MessageId!.Value.ToString(),
                TicketId = id.ToString(),
                SenderId = senderId,
                SenderName = senderName,
                SenderRole = isSupport ? "Support" : "User",
                Message = r.Message,
                MediaUrl = r.MediaUrl,
                MessageType = r.MessageType,
                CreatedAt = r.CreatedAt!.Value
            };
            await Web.Hubs.SupportHub.BroadcastMessage(hubContext, id.ToString(), liveMessage);

            return Api.Created(new SupportMessageData(r.MessageId!.Value, r.Message ?? "", r.MediaUrl, r.MessageType, r.CreatedAt!.Value));
        })
        .WithName("PostSupportMessage")
        .Produces<ApiResponse<SupportMessageData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        // PUT /support/tickets/:id/status
        g.MapPut("/tickets/{id:guid}/status", async (Guid id, UpdateTicketStatusCommand cmd, ISender sender, Microsoft.AspNetCore.SignalR.IHubContext<Web.Hubs.SupportHub> hubContext) =>
        {
            var r = await sender.Send(cmd with { TicketId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");

            // Broadcast status change
            await Web.Hubs.SupportHub.BroadcastStatusChange(hubContext, id.ToString(), r.Status ?? "");

            return Api.Ok(new SupportTicketStatusData(r.TicketId, r.Status));
        })
        .WithName("UpdateSupportTicketStatus")
        .Produces<ApiResponse<SupportTicketStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.SupportAccess); // Only support/admin can change status

        // POST /support/tickets/:id/assign
        g.MapPost("/tickets/{id:guid}/assign", async (Guid id, ClaimsPrincipal cp, ISender sender, Microsoft.AspNetCore.SignalR.IHubContext<Web.Hubs.SupportHub> hubContext) =>
        {
            var r = await sender.Send(new AssignTicketCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            
            var agentName = cp.FindFirstValue("FullName") ?? cp.FindFirstValue(ClaimTypes.Name) ?? "Support Agent";
            await Web.Hubs.SupportHub.BroadcastAssignmentChange(hubContext, id.ToString(), r.AssignedAgentId, agentName);
            
            return Api.Ok(new { AssignedAgentId = r.AssignedAgentId });
        })
        .WithName("AssignSupportTicket")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.SupportAccess);

        // POST /support/tickets/:id/unassign
        g.MapPost("/tickets/{id:guid}/unassign", async (Guid id, ISender sender, Microsoft.AspNetCore.SignalR.IHubContext<Web.Hubs.SupportHub> hubContext) =>
        {
            var r = await sender.Send(new UnassignTicketCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            
            await Web.Hubs.SupportHub.BroadcastAssignmentChange(hubContext, id.ToString(), null, null);
            
            return Api.Ok(new { Success = true });
        })
        .WithName("UnassignSupportTicket")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.SupportAccess);
    }
}
