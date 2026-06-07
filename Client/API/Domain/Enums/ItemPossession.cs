namespace Domain.Enums;

public enum ItemPossession
{
    Owner,      // Item is with the owner
    Renter,     // Item is with the renter
    Expert,     // Item is with the expert for verification
    InTransit   // Item is in transit (delivery)
}
