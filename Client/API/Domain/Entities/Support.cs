using Domain.Enums;

namespace Domain.Entities;

/// <summary>Matches the `support_tickets` table.</summary>
public class SupportTicket
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public SupportTicketType Type { get; set; } = SupportTicketType.General;
    public SupportTicketStatus Status { get; set; } = SupportTicketStatus.Open;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public ICollection<SupportMessage> Messages { get; set; } = new List<SupportMessage>();
}

/// <summary>Matches the `support_messages` table.</summary>
public class SupportMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TicketId { get; set; }
    public long SenderId { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public SupportTicket Ticket { get; set; } = null!;
    public ApplicationUser Sender { get; set; } = null!;
}
