namespace Domain.Enums;

public enum SupportTicketStatus
{
    Open,
    InProgress,
    AwaitingCustomer,
    AwaitingSupport,
    Resolved,
    Closed
}

public enum SupportTicketType
{
    General,
    Billing,
    Rental,
    Payment,
    Technical,
    Other
}
