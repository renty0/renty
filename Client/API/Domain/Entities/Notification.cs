namespace Domain.Entities;

/// <summary>Matches the `notifications` table.</summary>
public class Notification
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    /// <summary>Arabic title for bilingual notifications.</summary>
    public string? TitleAr { get; set; }
    /// <summary>Arabic message for bilingual notifications.</summary>
    public string? MessageAr { get; set; }
    /// <summary>chat | rental | item | system | support</summary>
    public string Type { get; set; } = "system";
    /// <summary>Frontend route to navigate to when clicked, e.g. /chats/abc</summary>
    public string? ActionUrl { get; set; }
    public bool IsRead { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
}
