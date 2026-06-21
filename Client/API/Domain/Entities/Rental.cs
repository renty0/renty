using Domain.Enums;

namespace Domain.Entities;

/// <summary>Matches the `rentals` table — System Design v2.0 compliant.</summary>
public class Rental
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public Guid ItemId { get; set; }
    public Guid? OrderId { get; set; }
    public decimal RentalPrice { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime? ActualReturnDate { get; set; }
    public decimal LateFee { get; set; } = 0;
    public RentalStatus Status { get; set; } = RentalStatus.Pending;
    public decimal DepositAmount { get; set; } = 0;
    public DepositStatus DepositStatus { get; set; } = DepositStatus.Held;
    public string? Notes { get; set; }

    
    public int CurrentTransferSequence { get; set; } = 1;
    public bool RenterWantsExpertReview { get; set; } = false;
    public bool OwnerWantsExpertReview { get; set; } = false;
    public decimal ExpertReviewFee { get; set; } = 0;
    public bool IsExpertPaid { get; set; } = false;
    public long? AssignedExpertId { get; set; }
    public ItemPossession CurrentPossession { get; set; } = ItemPossession.Owner;
    public DeliveryMethod DeliveryMethod { get; set; } = DeliveryMethod.ByHand;
    public DateTime? DesiredDeliveryDate { get; set; }
    public string? DeliveryNotes { get; set; }

    // ── System Design v2.0 additions ──────────────────────────────────────────
    /// <summary>Platform commission locked at creation time. Default 15%.</summary>
    public decimal PlatformCommissionPercent { get; set; } = 15.00m;

    /// <summary>Cancellation fee charged based on the item's cancellation policy tier.</summary>
    public decimal CancellationFee { get; set; } = 0;

    /// <summary>Whether the renter opted for hub-based expert evaluation.</summary>
    public bool HasHubEvaluation { get; set; } = false;

    /// <summary>Who pays for the hub evaluation: Owner, Renter, or Shared.</summary>
    public HubEvaluationPayer? EvaluationPayer { get; set; }

    /// <summary>Guarantee method: deposit_upfront or card_pre_authorization.</summary>
    public RentalGuaranteeMethod GuaranteeMethod { get; set; } = RentalGuaranteeMethod.DepositUpfront;

    /// <summary>How item returns to owner (or hub) after rental.</summary>
    public DeliveryMethod? DeliveryMethodToHubReturn { get; set; }

    /// <summary>How the item is delivered from the expert to the renter after BeforeRent review.</summary>
    public DeliveryMethod? DeliveryMethodFromExpert { get; set; }

    /// <summary>Fee charged when expert rejects item condition (fault-based).</summary>
    public decimal RejectionFeeAmount { get; set; } = 0;

    /// <summary>Who is at fault for rejection: owner or renter.</summary>
    public PenaltyFault? RejectionFault { get; set; }
    // ──────────────────────────────────────────────────────────────────────────

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser? AssignedExpert { get; set; }

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public Item Item { get; set; } = null!;
    public Order? Order { get; set; }
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<ItemVerification> Verifications { get; set; } = new List<ItemVerification>();
    public ICollection<RentalImage> Images { get; set; } = new List<RentalImage>();
    public ICollection<RentalExtension> Extensions { get; set; } = new List<RentalExtension>();
    public ICollection<RentalTransfer> Transfers { get; set; } = new List<RentalTransfer>();
}
