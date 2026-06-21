namespace Domain.Enums;

public enum TransferActorType
{
    Owner,
    Renter,
    Expert,
    DeliveryAgent,
    System
}

public enum TransferStatus
{
    Pending,
    WaitingForCode,
    Completed,
    Failed,
    Cancelled
}

public enum TransferPhase
{
    Handoff,
    Return
}
