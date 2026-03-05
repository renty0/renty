namespace Domain.Enums;

/// <summary>
/// Item status matching the new DB schema (items table).
/// </summary>
public enum NewItemStatus
{
    Available,
    Rented,
    UnderReview,
    Suspended,
    Removed
}
