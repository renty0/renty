using Application.Common.Interfaces;
using Application.Features.Chats;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;
using Microsoft.EntityFrameworkCore;

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
            return Api.Created(new { chatId = r.ChatId });
        })
        .WithName("CreateChat")
        .Produces<ApiResponse<CreateChatResponse>>(StatusCodes.Status201Created)
        .RequireAuthorization();

        // GET /chats
        g.MapGet("/", async (ISender sender) =>
        {
            var r = await sender.Send(new GetChatsQuery());
            return Api.Ok(r);
        })
        .WithName("GetChats")
        .Produces<ApiResponse<GetChatsResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        // POST /chats/:id/messages
        g.MapPost("/{id:guid}/messages", async (Guid id, PostChatMessageCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { ChatId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(r);
        })
        .WithName("PostChatMessage")
        .Produces<ApiResponse<PostChatMessageResponse>>(StatusCodes.Status201Created)
        .RequireAuthorization();

        // GET /chats/:id/messages
        g.MapGet("/{id:guid}/messages", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetChatMessagesQuery(id));
            if (!r.Found) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r);
        })
        .WithName("GetChatMessages")
        .Produces<ApiResponse<GetChatMessagesResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        g.MapDelete("/{id:guid}", async (Guid id, ISender sender) =>
        {
            // Chat deletion is intentionally disabled for all users.
            return Api.Fail("Chat deletion is disabled.", 403);
        })
        .WithName("DeleteChat")
        .Produces<ApiResponse<string>>(StatusCodes.Status200OK)
        .RequireAuthorization();
    }
}
