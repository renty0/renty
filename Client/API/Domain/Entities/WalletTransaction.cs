using Domain.Enums;

namespace Domain.Entities;

public enum TransactionType
{
    RentalEarnings, // Credit for owner after a successful rental
    Withdrawal,     // Debit when owner withdraws money
    Penalty,        // Debit when owner or renter is penalized
    Refund,         // Credit for a refund
    RentalIncome,   // Alias for RentalEarnings
    Adjustment,     // Forfeited deposit or other adjustment
    EscrowHold,     // Debit from Available, Credit to Pending (Renter)
    EscrowRelease,  // Debit from Pending, Credit to Available (Renter refund)
    PendingEarnings // Credit to Pending, eventually clearing to Available (Owner)
}

public class WalletTransaction
{
    public Guid Id { get; set; }
    public long UserId { get; set; }
    public ApplicationUser User { get; set; } = null!;
    
    public decimal Amount { get; set; } // Can be positive (credit) or negative (debit)
    public TransactionType Type { get; set; }
    public string Description { get; set; } = string.Empty;
    public Guid? RelatedRentalId { get; set; } // Reference to rental if applicable
    public string? ReferenceId { get; set; } // E.g., Vodafone cash ref for withdrawal
    
    public bool IsPending { get; set; } = false; // True if this transaction affects PendingBalance
    public DateTimeOffset? ReleaseDate { get; set; } // When the funds should clear
    
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
