using Domain.Enums;

namespace Domain.Entities;

public class IdVerification
{
    public Guid Id { get; set; }
    public long UserId { get; set; }
    public ApplicationUser User { get; set; } = null!;
    
    public string FrontImageUrl { get; set; } = string.Empty;
    public string BackImageUrl { get; set; } = string.Empty;
    
    public VerificationStatus Status { get; set; } = VerificationStatus.Pending;
    public string? RejectionReason { get; set; }
    
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    
    public long? ReviewedById { get; set; }
    public ApplicationUser? ReviewedBy { get; set; }
    public DateTimeOffset? ReviewedAt { get; set; }
}
