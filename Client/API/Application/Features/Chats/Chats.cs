using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Chats;

public record ChatListDto(
    Guid Id,
    string OtherUserFirstName,
    string OtherUserLastName,
    string? OtherUserProfileImage,
    string? LastMessage,
    MessageType LastMessageType,
    int UnreadCount,
    DateTime? LastMessageAt
);

public record ChatMessageDto(
    Guid Id, 
    long SenderId, 
    string? Message, 
    string? MediaUrl,
    MessageType MessageType,
    Guid? ContextItemId,
    bool IsRead, 
    DateTime CreatedAt
);

public record CreateChatCommand(long UserId, Guid? ItemId = null) : IRequest<CreateChatResponse>;
public record CreateChatResponse(bool Success, string? Error, Guid? ChatId);

public class CreateChatCommandHandler : IRequestHandler<CreateChatCommand, CreateChatResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CreateChatCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreateChatResponse> Handle(CreateChatCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new CreateChatResponse(false, "Unauthorized.", null);
        if (_currentUser.Id.Value == request.UserId)
            return new CreateChatResponse(false, "Cannot start a chat with yourself.", null);

        var u1 = Math.Min(_currentUser.Id.Value, request.UserId);
        var u2 = Math.Max(_currentUser.Id.Value, request.UserId);

        var existing = await _context.Chats
            .FirstOrDefaultAsync(c => c.User1Id == u1 && c.User2Id == u2, ct);

        if (existing != null) return new CreateChatResponse(true, null, existing.Id);

        var chat = new Chat { User1Id = u1, User2Id = u2, CreatedAt = DateTime.UtcNow };
        _context.Chats.Add(chat);
        await _context.SaveChangesAsync(ct);
        return new CreateChatResponse(true, null, chat.Id);
    }
}

public record GetChatsQuery : IRequest<GetChatsResponse>;
public record GetChatsResponse(List<ChatListDto> Chats);

public class GetChatsQueryHandler : IRequestHandler<GetChatsQuery, GetChatsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetChatsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetChatsResponse> Handle(GetChatsQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new GetChatsResponse(new List<ChatListDto>());
        
        var uid = _currentUser.Id!.Value;
        var chats = await _context.Chats
            .Include(c => c.User1)
            .Include(c => c.User2)
            .Include(c => c.Messages)
            .Where(c => c.User1Id == uid || c.User2Id == uid)
            .Select(c => new
            {
                c.Id,
                OtherUser = c.User1Id == uid ? c.User2 : c.User1,
                LastMsg = c.Messages.OrderByDescending(m => m.CreatedAt).FirstOrDefault(),
                UnreadCount = c.Messages.Count(m => !m.IsRead && m.SenderId != uid)
            })
            .ToListAsync(ct);

        var result = chats.Select(c => new ChatListDto(
            c.Id,
            c.OtherUser.FirstName,
            c.OtherUser.LastName,
            c.OtherUser.ProfilePictureUrl,
            c.LastMsg?.Message ?? (c.LastMsg?.MessageType != MessageType.Text ? $"[{c.LastMsg?.MessageType}]" : null),
            c.LastMsg?.MessageType ?? MessageType.Text,
            c.UnreadCount,
            c.LastMsg?.CreatedAt
        ))
        .OrderByDescending(c => c.LastMessageAt)
        .ToList();

        return new GetChatsResponse(result);
    }
}

public record PostChatMessageCommand(
    Guid ChatId, 
    string? Message = null, 
    string? MediaUrl = null, 
    MessageType MessageType = MessageType.Text,
    Guid? ContextItemId = null
) : IRequest<PostChatMessageResponse>;

public record PostChatMessageResponse(
    bool Success, 
    string? Error, 
    Guid? MessageId, 
    string? Message, 
    string? MediaUrl,
    MessageType MessageType,
    DateTime? CreatedAt
);

public interface IChatNotifier
{
    Task SendMessageAsync(Guid chatId, object payload, CancellationToken ct);
}

public class PostChatMessageCommandHandler : IRequestHandler<PostChatMessageCommand, PostChatMessageResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IChatNotifier? _notifier;

    public PostChatMessageCommandHandler(
        IApplicationDbContext context,
        IUser currentUser,
        IChatNotifier? notifier = null)  
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<PostChatMessageResponse> Handle(PostChatMessageCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new PostChatMessageResponse(false, "Unauthorized.", null, null, null, MessageType.Text, null);

        var chat = await _context.Chats.FirstOrDefaultAsync(c => c.Id == request.ChatId, ct);
        if (chat == null) return new PostChatMessageResponse(false, "Chat not found.", null, null, null, MessageType.Text, null);

        if (chat.User1Id != _currentUser.Id.Value && chat.User2Id != _currentUser.Id.Value)
            return new PostChatMessageResponse(false, "Forbidden.", null, null, null, MessageType.Text, null);

        var msg = new ChatMessage
        {
            ChatId = request.ChatId,
            SenderId = _currentUser.Id.Value,
            Message = request.Message,
            MediaUrl = request.MediaUrl,
            MessageType = request.MessageType,
            ContextItemId = request.ContextItemId,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };
        _context.ChatMessages.Add(msg);
        await _context.SaveChangesAsync(ct);

        if (_notifier != null)
        {
            await _notifier.SendMessageAsync(request.ChatId, new
            {
                id = msg.Id,
                chatId = msg.ChatId,
                senderId = msg.SenderId,
                message = msg.Message,
                mediaUrl = msg.MediaUrl,
                messageType = msg.MessageType,
                contextItemId = msg.ContextItemId,
                createdAt = msg.CreatedAt
            }, ct);
        }

        return new PostChatMessageResponse(true, null, msg.Id, msg.Message, msg.MediaUrl, msg.MessageType, msg.CreatedAt);
    }
}

public record GetChatMessagesQuery(Guid ChatId) : IRequest<GetChatMessagesResponse>;
public record GetChatMessagesResponse(bool Found, string? Error, List<ChatMessageDto>? Messages);

public class GetChatMessagesQueryHandler : IRequestHandler<GetChatMessagesQuery, GetChatMessagesResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetChatMessagesQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetChatMessagesResponse> Handle(GetChatMessagesQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new GetChatMessagesResponse(false, "Unauthorized.", null);

        var chat = await _context.Chats.FirstOrDefaultAsync(c => c.Id == request.ChatId, ct);
        if (chat == null) return new GetChatMessagesResponse(false, "Chat not found.", null);
        if (chat.User1Id != _currentUser.Id.Value && chat.User2Id != _currentUser.Id.Value)
            return new GetChatMessagesResponse(false, "Forbidden.", null);

        var messages = await _context.ChatMessages
            .Where(m => m.ChatId == request.ChatId)
            .OrderBy(m => m.CreatedAt)
            .Select(m => new ChatMessageDto(
                m.Id, 
                m.SenderId, 
                m.Message, 
                m.MediaUrl,
                m.MessageType,
                m.ContextItemId,
                m.IsRead, 
                m.CreatedAt))
            .ToListAsync(ct);

        var unread = await _context.ChatMessages
            .Where(m => m.ChatId == request.ChatId && m.SenderId != _currentUser.Id.Value && !m.IsRead)
            .ToListAsync(ct);
            
        foreach (var m in unread) m.IsRead = true;
        if (unread.Any()) await _context.SaveChangesAsync(ct);

        return new GetChatMessagesResponse(true, null, messages);
    }
}
