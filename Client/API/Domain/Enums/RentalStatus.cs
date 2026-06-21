namespace Domain.Enums;

/// <summary>
/// Full rental lifecycle matching System Design v2.0.
/// Flow: Pending → Confirmed → Paid → InDelivery → Active → [Extended] → Returned → Completed
/// Alt flows: Cancelled, Disputed, Overdue, Rejected
/// </summary>
public enum RentalStatus
{
    Pending,        // = "requested" in spec — renter submitted request
    Confirmed,      // Owner approved the request
    AwaitingPickup, // Owner selected handoff method, waiting for first transfer
    Paid,           // Payment received (order status = paid)
    InDelivery,     // Item in transit to renter
    Active,         // Renter has the item
    Extended,       // Extension approved, new end date set
    Returned,       // Renter returned item, awaiting owner confirmation
    Completed,      // Owner confirmed return, rental closed
    Cancelled,      // Cancelled by renter (with policy-based fee)
    Disputed,       // Dispute opened on this rental
    Overdue,        // Past end_date + grace period
    Rejected        // Owner rejected the initial request
}
