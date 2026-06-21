using Domain.Enums;

namespace Domain.Entities;

public class RentalTransfer
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RentalId { get; set; }
    
    public TransferActorType FromActorType { get; set; }
    public long? FromActorId { get; set; }
    
    public TransferActorType ToActorType { get; set; }
    public long? ToActorId { get; set; }
    
    public string VerificationCode { get; set; } = Guid.NewGuid().ToString("N")[..6].ToUpper();
    
    public TransferStatus Status { get; set; } = TransferStatus.Pending;
    public TransferPhase Phase { get; set; }
    
    public int Sequence { get; set; }
    public string? Notes { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? CompletedAt { get; set; }
    
    // Navigation
    public Rental Rental { get; set; } = null!;
}
