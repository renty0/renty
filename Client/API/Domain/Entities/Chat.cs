namespace Domain.Entities;

/// <summary>Matches the `chats` table. Unique on (user1_id, user2_id).</summary>
public class Chat
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long User1Id { get; set; }
    public long User2Id { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid? ItemId { get; set; }
    
    public bool DeletedByUser1 { get; set; } = false;
    public bool DeletedByUser2 { get; set; } = false;
    
    // Navigation
    public ApplicationUser User1 { get; set; } = null!;
    public ApplicationUser User2 { get; set; } = null!;
    public Item? Item { get; set; }
    public ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();
}

/// <summary>Matches the `chat_messages` table.</summary>
public class ChatMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ChatId { get; set; }
    public long SenderId { get; set; }
    public string? Message { get; set; }
    public string? MediaUrl { get; set; }
    public Domain.Enums.MessageType MessageType { get; set; } = Domain.Enums.MessageType.Text;
    public Guid? ContextItemId { get; set; } // Optional item context
    public bool IsRead { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Chat Chat { get; set; } = null!;
    public ApplicationUser Sender { get; set; } = null!;
    public Item? ContextItem { get; set; }
}
