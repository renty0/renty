using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace Application.Features.Chats;

public record ChatListDto(
    Guid Id,
    string OtherUserFirstName,
    string OtherUserLastName,
    string? OtherUserProfileImage,
    string? LastMessage,
    MessageType LastMessageType,
    int UnreadCount,
    DateTime? LastMessageAt,
    Guid? ItemId = null,
    string? ItemTitle = null,
    string? ItemImage = null,
    DateTimeOffset? OtherUserLastLoginAt = null
);

public record ChatMessageDto(
    Guid Id, 
    long SenderId, 
    string? Message, 
    string? MediaUrl,
    MessageType MessageType,
    Guid? ContextItemId,
    string? ContextItemTitle,
    string? ContextItemImage,
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
            .Where(c => c.User1Id == u1 && c.User2Id == u2)
            .OrderByDescending(c => c.CreatedAt)
            .FirstOrDefaultAsync(ct);

        if (existing != null) return new CreateChatResponse(true, null, existing.Id);

        var chat = new Chat { User1Id = u1, User2Id = u2, ItemId = null, CreatedAt = DateTime.UtcNow };
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
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetChatsQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetChatsResponse> Handle(GetChatsQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new GetChatsResponse(new List<ChatListDto>());
        
        var uid = _currentUser.Id!.Value;
        var chats = await _context.Chats
            .Include(c => c.User1)
            .Include(c => c.User2)
            .Include(c => c.Item)
                .ThenInclude(i => i.Images)
                    .ThenInclude(img => img.Image)
            .Include(c => c.Messages)
            .Where(c => (c.User1Id == uid && !c.DeletedByUser1) || (c.User2Id == uid && !c.DeletedByUser2))
            .Select(c => new
            {
                c.Id,
                OtherUser = c.User1Id == uid ? c.User2 : c.User1,
                LastMsg = c.Messages.OrderByDescending(m => m.CreatedAt).FirstOrDefault(),
                UnreadCount = c.Messages.Count(m => !m.IsRead && m.SenderId != uid),
                c.ItemId,
                ItemTitle = c.Item != null ? c.Item.TitleAr : null, 
                ItemImage = c.Item != null ? c.Item.Images.OrderByDescending(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault() : null,
                c.CreatedAt
            })
            .ToListAsync(ct);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}:{requestUrl.Host.Port}" : "";
        baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : "";

        var groupedChats = chats
            .GroupBy(c => c.OtherUser.Id)
            .Select(g => g.OrderByDescending(c => c.LastMsg?.CreatedAt ?? c.CreatedAt).First())
            .ToList();

        var result = groupedChats.Select(c => new ChatListDto(
            c.Id,
            c.OtherUser.FirstName,
            c.OtherUser.LastName,
            !string.IsNullOrEmpty(c.OtherUser.ProfilePictureUrl)
                ? (c.OtherUser.ProfilePictureUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase)
                    ? c.OtherUser.ProfilePictureUrl
                    : $"{baseUrl}/{c.OtherUser.ProfilePictureUrl.TrimStart('/')}")
                : null,
            c.LastMsg?.Message ?? (c.LastMsg != null && c.LastMsg.MessageType != MessageType.Text ? $"[{c.LastMsg.MessageType}]" : null),
            c.LastMsg?.MessageType ?? MessageType.Text,
            c.UnreadCount,
            c.LastMsg?.CreatedAt ?? c.CreatedAt,
            c.ItemId,
            c.ItemTitle,
            !string.IsNullOrEmpty(c.ItemImage)
                ? (c.ItemImage.StartsWith("http", StringComparison.OrdinalIgnoreCase)
                    ? c.ItemImage
                    : $"{baseUrl}/{c.ItemImage.Replace("\\", "/").TrimStart('/')}")
                : null,
            c.OtherUser.LastLoginAt
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
    Task SendMessageAsync(Guid chatId, IEnumerable<string> userIds, object payload, CancellationToken ct);
}

public class PostChatMessageCommandHandler : IRequestHandler<PostChatMessageCommand, PostChatMessageResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IChatNotifier? _notifier;
    private readonly INotificationSender _notificationSender;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public PostChatMessageCommandHandler(
        IApplicationDbContext context,
        IUser currentUser,
        IHttpContextAccessor httpContextAccessor,
        INotificationSender notificationSender,
        IChatNotifier? notifier = null)  
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
        _notificationSender = notificationSender;
        _httpContextAccessor = httpContextAccessor;
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

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : "";
        var mediaUrl = !string.IsNullOrEmpty(msg.MediaUrl) ? $"{baseUrl}/{msg.MediaUrl.TrimStart('/')}" : msg.MediaUrl;

        string? contextItemTitle = null;
        string? contextItemImage = null;

        if (msg.ContextItemId.HasValue)
        {
            var item = await _context.Items.Include(i => i.Images).ThenInclude(img => img.Image).FirstOrDefaultAsync(i => i.Id == msg.ContextItemId.Value, ct);
            if (item != null)
            {
                contextItemTitle = item.TitleAr; // or TitleEn depending on logic, but TitleAr is safe fallback
                var primaryImage = item.Images.OrderByDescending(img => img.IsPrimary).FirstOrDefault()?.Image?.StoragePath;
                if (primaryImage != null)
                {
                    contextItemImage = primaryImage.StartsWith("http") ? primaryImage : $"{baseUrl}/{primaryImage.TrimStart('/')}";
                }
            }
        }

        if (_notifier != null)
        {
            var userIds = new[] { chat.User1Id.ToString(), chat.User2Id.ToString() };
            await _notifier.SendMessageAsync(request.ChatId, userIds, new
            {
                id = msg.Id,
                chatId = msg.ChatId,
                senderId = msg.SenderId,
                message = msg.Message,
                mediaUrl = mediaUrl,
                messageType = msg.MessageType,
                contextItemId = msg.ContextItemId,
                contextItemTitle = contextItemTitle,
                contextItemImage = contextItemImage,
                createdAt = msg.CreatedAt
            }, ct);
        }

        // Send System Notification to recipient
        var recipientId = chat.User1Id == _currentUser.Id.Value ? chat.User2Id : chat.User1Id;
        var sender = await _context.Users.FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);
        var senderName = sender?.FirstName ?? "Someone";
        
        await _notificationSender.SendToUserAsync(
            recipientId,
            "New Message",
            $"{senderName} sent you a message: {msg.Message ?? "[Media]"}",
            "chat",
            $"/chats/{chat.Id}",
            ct,
            titleAr: "رسالة جديدة",
            messageAr: $"{senderName} أرسل لك رسالة: {msg.Message ?? "[وسائط]"}");

        return new PostChatMessageResponse(true, null, msg.Id, msg.Message, mediaUrl, msg.MessageType, msg.CreatedAt);
    }
}

public record DeleteChatCommand(Guid ChatId) : IRequest<bool>;

public class DeleteChatCommandHandler : IRequestHandler<DeleteChatCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public DeleteChatCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(DeleteChatCommand request, CancellationToken ct)
    {
        // Chat deletion is disabled for all users.
        return await Task.FromResult(false);
    }
}

public record GetChatMessagesQuery(Guid ChatId) : IRequest<GetChatMessagesResponse>;
public record GetChatMessagesResponse(bool Found, string? Error, List<ChatMessageDto>? Messages, ChatListDto? ChatMetadata = null);

public class GetChatMessagesQueryHandler : IRequestHandler<GetChatMessagesQuery, GetChatMessagesResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetChatMessagesQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetChatMessagesResponse> Handle(GetChatMessagesQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new GetChatMessagesResponse(false, "Unauthorized.", null);

        var chat = await _context.Chats
            .Include(c => c.User1)
            .Include(c => c.User2)
            .Include(c => c.Item)
                .ThenInclude(i => i.Images)
                    .ThenInclude(img => img.Image)
            .FirstOrDefaultAsync(c => c.Id == request.ChatId, ct);

        if (chat == null) return new GetChatMessagesResponse(false, "Chat not found.", null);
        
        var uid = _currentUser.Id.Value;
        if (chat.User1Id != uid && chat.User2Id != uid)
            return new GetChatMessagesResponse(false, "Forbidden.", null);

        var otherUser = chat.User1Id == uid ? chat.User2 : chat.User1;
        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : "";

        var otherUserProfileImage = otherUser.ProfilePictureUrl;
        if (!string.IsNullOrEmpty(otherUserProfileImage) && !otherUserProfileImage.StartsWith("http"))
        {
            otherUserProfileImage = $"{baseUrl}/{otherUserProfileImage.TrimStart('/')}";
        }

        string? itemImage = null;
        var primaryImage = chat.Item?.Images.OrderByDescending(i => i.IsPrimary).FirstOrDefault();
        if (primaryImage?.Image != null)
        {
            var path = primaryImage.Image.StoragePath;
            itemImage = path.StartsWith("http", StringComparison.OrdinalIgnoreCase) 
                ? path 
                : $"{baseUrl}/{path.Replace("\\", "/").TrimStart('/')}";
        }

        var metadata = new ChatListDto(
            chat.Id,
            otherUser.FirstName,
            otherUser.LastName,
            otherUserProfileImage,
            null,
            MessageType.Text,
            0,
            chat.CreatedAt,
            chat.ItemId,
            chat.Item?.TitleAr,
            itemImage,
            otherUser.LastLoginAt
        );

        var messages = await _context.ChatMessages
            .Include(m => m.ContextItem)
                .ThenInclude(i => i.Images)
            .Where(m => m.Chat.User1Id == chat.User1Id && m.Chat.User2Id == chat.User2Id)
            .OrderBy(m => m.CreatedAt)
            .Select(m => new ChatMessageDto(
                m.Id, 
                m.SenderId, 
                m.Message, 
                !string.IsNullOrEmpty(m.MediaUrl) 
                    ? (m.MediaUrl.StartsWith("http") ? m.MediaUrl : $"{baseUrl}/{m.MediaUrl.TrimStart('/')}")
                    : m.MediaUrl,
                m.MessageType,
                m.ContextItemId,
                m.ContextItem != null ? m.ContextItem.TitleAr : null,
                m.ContextItem != null ? (m.ContextItem.Images.OrderByDescending(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault() != null ? (m.ContextItem.Images.OrderByDescending(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault()!.StartsWith("http") ? m.ContextItem.Images.OrderByDescending(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault() : $"{baseUrl}/{m.ContextItem.Images.OrderByDescending(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault()!.TrimStart('/')}") : null) : null,
                m.IsRead, 
                m.CreatedAt))
            .ToListAsync(ct);

        var unread = await _context.ChatMessages
            .Where(m => m.Chat.User1Id == chat.User1Id && m.Chat.User2Id == chat.User2Id && m.SenderId != uid && !m.IsRead)
            .ToListAsync(ct);
            
        foreach (var m in unread) m.IsRead = true;
        if (unread.Any()) await _context.SaveChangesAsync(ct);

        // Also mark related system notifications as read
        var unreadNotifs = await _context.Notifications
            .Where(n => n.UserId == uid && !n.IsRead && n.ActionUrl == $"/chats/{request.ChatId}")
            .ToListAsync(ct);
            
        foreach (var n in unreadNotifs) n.IsRead = true;
        if (unreadNotifs.Any()) await _context.SaveChangesAsync(ct);

        return new GetChatMessagesResponse(true, null, messages, metadata);
    }
}
