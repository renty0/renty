using Application.Features.Support;
using MediatR;
using Microsoft.AspNetCore.Http;
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
        g.MapGet("/tickets", async (ISender sender) =>
        {
            var r = await sender.Send(new GetTicketsQuery());
            return Api.Ok(r);
        })
        .WithName("GetSupportTickets")
        .Produces<ApiResponse<GetTicketsResponse>>(StatusCodes.Status200OK);

        // POST /support/tickets/:id/messages
        g.MapPost("/tickets/{id:guid}/messages", async (Guid id, PostSupportMessageCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { TicketId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            // MessageId and CreatedAt are Guid?/DateTime? — use .Value on success
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
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}
