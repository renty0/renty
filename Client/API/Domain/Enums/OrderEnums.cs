namespace Domain.Enums;

public enum OrderStatus
{
    Pending,
    Paid,
    Shipped,
    Delivered,
    Cancelled
}

public enum PaymentStatus
{
    Pending,
    Success,
    Failed
}

public enum PaymentMethod
{
    VodafoneCash,
    Fawry,
    Paymob,
    CreditCard,
    BankTransfer
}

public enum DepositStatus
{
    Held,
    Returned,
    Forfeited
}

public enum DeliveryStatus
{
    Processing,
    Shipped,
    InTransit,
    Delivered,
    Returned,
    Cancelled
}

public enum VerificationCheck
{
    BeforeRent,
    AfterReturn
}

public enum VerificationStatus
{
    Pending,
    Approved,
    Rejected
}
