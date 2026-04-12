namespace Domain.Enums;

public enum ItemStatus
{
    Draft = 1,          // Item not yet published
    Available = 2,      // Available for rent
    Rented = 3,         // Currently rented out
    Unavailable = 4,    // Temporarily unavailable
    Archived = 5,       // No longer listed
    PendingApproval = 6,// Needs admin review
    Rejected = 7        // Admin rejected the listing
}
