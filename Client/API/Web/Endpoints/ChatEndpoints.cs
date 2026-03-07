using Application.Features.Chats;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class ChatEndpoints
{
    public static void MapChatEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/chats").WithTags("Chat");

        // POST /chats
        g.MapPost("/", async (CreateChatCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new ChatCreateData(r.ChatId));
        })
        .WithName("CreateChat")
        .Produces<ApiResponse<ChatCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /chats
        g.MapGet("/", async (ISender sender) =>
        {
            var r = await sender.Send(new GetChatsQuery());
            return Api.Ok(r);
        })
        .WithName("GetChats")
        .Produces<ApiResponse<GetChatsResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.CanTransact);

        // POST /chats/:id/messages
        g.MapPost("/{id:guid}/messages", async (Guid id, PostChatMessageCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { ChatId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new ChatMessageData(r.MessageId, r.Message, r.CreatedAt));
        })
        .WithName("PostChatMessage")
        .Produces<ApiResponse<ChatMessageData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /chats/:id/messages
        g.MapGet("/{id:guid}/messages", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetChatMessagesQuery(id));
            if (!r.Found) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r);
        })
        .WithName("GetChatMessages")
        .Produces<ApiResponse<GetChatMessagesResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.CanTransact);
    }
}
