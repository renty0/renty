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
        g.MapPost("/tickets", async (CreateTicketCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            // TicketId is Guid? — use .Value (it's non-null on success)
            return Api.Created(new SupportCreateTicketData(r.TicketId!.Value, r.Status));
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
                CreatedAt = r.CreatedAt!.Value
            };
            await Web.Hubs.SupportHub.BroadcastMessage(hubContext, id.ToString(), liveMessage);

            return Api.Created(new SupportMessageData(r.MessageId!.Value, r.Message ?? "", r.CreatedAt!.Value));
        })
        .WithName("PostSupportMessage")
        .Produces<ApiResponse<SupportMessageData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        // PUT /support/tickets/:id/status
        g.MapPut("/tickets/{id:guid}/status", async (Guid id, UpdateTicketStatusCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { TicketId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new SupportTicketStatusData(r.TicketId, r.Status));
        })
        .WithName("UpdateSupportTicketStatus")
        .Produces<ApiResponse<SupportTicketStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.SupportAccess); // Only support/admin can change status
    }
}
