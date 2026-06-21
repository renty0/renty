namespace Domain.Enums;

/// <summary>Who pays for hub evaluation: matches DB enum hub_evaluation_payer.</summary>
public enum HubEvaluationPayer
{
    Owner,
    Renter,
    Shared
}

/// <summary>Guarantee method: matches DB enum rental_guarantee_method.</summary>
public enum RentalGuaranteeMethod
{
    DepositUpfront,
    CardPreAuthorization
}

/// <summary>Who is at fault for a penalty: matches DB enum penalty_fault.</summary>
public enum PenaltyFault
{
    Owner,
    Renter
}

/// <summary>Cancellation policy tier: matches DB enum cancellation_policy.</summary>
public enum CancellationPolicy
{
    Flexible,   // Full refund 24h+, 50% within 24h
    Moderate,   // Full refund 72h+, 50% at 24-72h, 0% <24h
    Strict      // Full refund 7d+, 50% at 3-7d, 0% <3d
}

/// <summary>Status of a rental extension request.</summary>
public enum ExtensionStatus
{
    Pending,
    Approved,
    Rejected
}
