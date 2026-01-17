namespace Domain.Enums;

public enum RentRequestStatus
{
    Pending = 1,        // Request submitted, waiting for owner response
    Approved = 2,       // Owner approved the request
    Rejected = 3,       // Owner rejected the request
    Cancelled = 4,      // Renter cancelled the request
    Active = 5,         // Rental is currently active
    Completed = 6,      // Rental period completed successfully
    Disputed = 7        // There's a dispute that needs resolution
}
