using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Transfers;

public record GenerateHandoffTransfersCommand(Guid RentalId, DeliveryMethod Method) : IRequest<bool>;

public class GenerateHandoffTransfersCommandHandler : IRequestHandler<GenerateHandoffTransfersCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public GenerateHandoffTransfersCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(GenerateHandoffTransfersCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return false;

        // Check if handoff transfers already exist
        var existingTransfers = await _context.RentalTransfers
            .Where(t => t.RentalId == rental.Id && t.Phase == TransferPhase.Handoff)
            .AnyAsync(ct);
            
        if (existingTransfers) return false;

        rental.DeliveryMethod = request.Method; // Update rental with owner's choice

        bool hasExpert = rental.OwnerWantsExpertReview || rental.RenterWantsExpertReview || rental.HasHubEvaluation;
        bool hasDelivery = request.Method == DeliveryMethod.DeliveryService;

        var transfers = new List<RentalTransfer>();
        
        // Find highest sequence number to continue from if needed, otherwise start at 1
        int seq = await _context.RentalTransfers.Where(t => t.RentalId == rental.Id).Select(t => (int?)t.Sequence).MaxAsync(ct) ?? 0;
        seq++;

        if (hasExpert && hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Owner, TransferActorType.DeliveryAgent, TransferPhase.Handoff, rental.Item.OwnerId, null));
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.DeliveryAgent, TransferActorType.Expert, TransferPhase.Handoff, null, rental.AssignedExpertId));
        }
        else if (hasExpert && !hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Owner, TransferActorType.Expert, TransferPhase.Handoff, rental.Item.OwnerId, rental.AssignedExpertId));
        }
        else if (!hasExpert && hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Owner, TransferActorType.DeliveryAgent, TransferPhase.Handoff, rental.Item.OwnerId, null));
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.DeliveryAgent, TransferActorType.Renter, TransferPhase.Handoff, null, rental.UserId));
        }
        else
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Owner, TransferActorType.Renter, TransferPhase.Handoff, rental.Item.OwnerId, rental.UserId));
        }

        _context.RentalTransfers.AddRange(transfers);
        
        // If this is the first set of transfers, reset current sequence to the first one generated
        if (rental.CurrentTransferSequence == 0 || !await _context.RentalTransfers.AnyAsync(t => t.RentalId == rental.Id, ct))
        {
            rental.CurrentTransferSequence = seq - transfers.Count;
        }

        await _context.SaveChangesAsync(ct);
        return true;
    }

    private RentalTransfer CreateTransfer(Rental rental, int sequence, TransferActorType fromRole, TransferActorType toRole, TransferPhase phase, long? fromId, long? toId)
    {
        string code = new Random().Next(100000, 999999).ToString();
        
        if (rental.Verifications != null)
        {
            if (phase == TransferPhase.Handoff && toRole == TransferActorType.Expert)
            {
                var v = rental.Verifications.FirstOrDefault(x => x.CheckType == VerificationCheck.BeforeRent);
                if (v != null && !string.IsNullOrEmpty(v.VerificationCode)) code = v.VerificationCode;
            }
            else if (phase == TransferPhase.Return && toRole == TransferActorType.Expert)
            {
                var v = rental.Verifications.FirstOrDefault(x => x.CheckType == VerificationCheck.AfterReturn);
                if (v != null && !string.IsNullOrEmpty(v.VerificationCode)) code = v.VerificationCode;
            }
        }

        return new RentalTransfer
        {
            RentalId = rental.Id,
            FromActorType = fromRole,
            FromActorId = fromId,
            ToActorType = toRole,
            ToActorId = toId,
            Sequence = sequence,
            Phase = phase,
            Status = TransferStatus.WaitingForCode,
            VerificationCode = code
        };
    }
}

public record GenerateHandoffFromHubTransfersCommand(Guid RentalId, DeliveryMethod Method) : IRequest<bool>;

public class GenerateHandoffFromHubTransfersCommandHandler : IRequestHandler<GenerateHandoffFromHubTransfersCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public GenerateHandoffFromHubTransfersCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(GenerateHandoffFromHubTransfersCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return false;

        var expertVerification = rental.Verifications?.FirstOrDefault(v => v.CheckType == VerificationCheck.BeforeRent);
        if (expertVerification == null || expertVerification.Status != VerificationStatus.Approved)
            return false;

        rental.DeliveryMethodFromExpert = request.Method;

        bool hasDelivery = request.Method == DeliveryMethod.DeliveryService;

        var transfers = new List<RentalTransfer>();
        
        // For backwards compatibility with old rentals, delete any existing pending handoff transfers
        var existingPending = await _context.RentalTransfers
            .Where(t => t.RentalId == rental.Id && t.Phase == TransferPhase.Handoff && t.Sequence >= rental.CurrentTransferSequence && t.Status != TransferStatus.Completed)
            .ToListAsync(ct);
        
        if (existingPending.Any())
        {
            _context.RentalTransfers.RemoveRange(existingPending);
        }

        int seq = rental.CurrentTransferSequence;

        if (hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Expert, TransferActorType.DeliveryAgent, TransferPhase.Handoff, rental.AssignedExpertId, null));
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.DeliveryAgent, TransferActorType.Renter, TransferPhase.Handoff, null, rental.UserId));
        }
        else
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Expert, TransferActorType.Renter, TransferPhase.Handoff, rental.AssignedExpertId, rental.UserId));
        }

        _context.RentalTransfers.AddRange(transfers);
        await _context.SaveChangesAsync(ct);
        return true;
    }

    private RentalTransfer CreateTransfer(Rental rental, int sequence, TransferActorType fromRole, TransferActorType toRole, TransferPhase phase, long? fromId, long? toId)
    {
        string code = new Random().Next(100000, 999999).ToString();
        
        if (rental.Verifications != null)
        {
            if (phase == TransferPhase.Handoff && toRole == TransferActorType.Expert)
            {
                var v = rental.Verifications.FirstOrDefault(x => x.CheckType == VerificationCheck.BeforeRent);
                if (v != null && !string.IsNullOrEmpty(v.VerificationCode)) code = v.VerificationCode;
            }
            else if (phase == TransferPhase.Return && toRole == TransferActorType.Expert)
            {
                var v = rental.Verifications.FirstOrDefault(x => x.CheckType == VerificationCheck.AfterReturn);
                if (v != null && !string.IsNullOrEmpty(v.VerificationCode)) code = v.VerificationCode;
            }
        }

        return new RentalTransfer
        {
            RentalId = rental.Id,
            FromActorType = fromRole,
            FromActorId = fromId,
            ToActorType = toRole,
            ToActorId = toId,
            Sequence = sequence,
            Phase = phase,
            Status = TransferStatus.WaitingForCode,
            VerificationCode = code
        };
    }
}

public record GenerateReturnTransfersCommand(Guid RentalId, DeliveryMethod Method) : IRequest<bool>;

public class GenerateReturnTransfersCommandHandler : IRequestHandler<GenerateReturnTransfersCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public GenerateReturnTransfersCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(GenerateReturnTransfersCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return false;

        // Check if return transfers already exist - if so, just ensure sequence is correct and return success
        var existingReturnTransfers = await _context.RentalTransfers
            .Where(t => t.RentalId == rental.Id && t.Phase == TransferPhase.Return)
            .OrderBy(t => t.Sequence)
            .ToListAsync(ct);
            
        if (existingReturnTransfers.Any())
        {
            // Ensure CurrentTransferSequence points to the first non-completed return transfer
            var firstPending = existingReturnTransfers.FirstOrDefault(t => t.Status != TransferStatus.Completed);
            if (firstPending != null)
            {
                rental.CurrentTransferSequence = firstPending.Sequence;
                await _context.SaveChangesAsync(ct);
            }
            return true; // Already generated, treat as success
        }

        bool hasExpert = rental.OwnerWantsExpertReview || rental.RenterWantsExpertReview || rental.HasHubEvaluation;
        bool hasDelivery = request.Method == DeliveryMethod.DeliveryService;

        var transfers = new List<RentalTransfer>();
        
        int seq = await _context.RentalTransfers.Where(t => t.RentalId == rental.Id).Select(t => (int?)t.Sequence).MaxAsync(ct) ?? 0;
        seq++;

        if (hasExpert && hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Renter, TransferActorType.DeliveryAgent, TransferPhase.Return, rental.UserId, null));
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.DeliveryAgent, TransferActorType.Expert, TransferPhase.Return, null, rental.AssignedExpertId));
        }
        else if (hasExpert && !hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Renter, TransferActorType.Expert, TransferPhase.Return, rental.UserId, rental.AssignedExpertId));
        }
        else if (!hasExpert && hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Renter, TransferActorType.DeliveryAgent, TransferPhase.Return, rental.UserId, null));
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.DeliveryAgent, TransferActorType.Owner, TransferPhase.Return, null, rental.Item.OwnerId));
        }
        else
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Renter, TransferActorType.Owner, TransferPhase.Return, rental.UserId, rental.Item.OwnerId));
        }

        _context.RentalTransfers.AddRange(transfers);
        
        // Point CurrentTransferSequence to the first return transfer
        rental.CurrentTransferSequence = transfers.Min(t => t.Sequence);
        
        await _context.SaveChangesAsync(ct);
        return true;
    }

    private RentalTransfer CreateTransfer(Rental rental, int sequence, TransferActorType fromRole, TransferActorType toRole, TransferPhase phase, long? fromId, long? toId)
    {
        string code = new Random().Next(100000, 999999).ToString();
        
        if (rental.Verifications != null)
        {
            if (phase == TransferPhase.Handoff && toRole == TransferActorType.Expert)
            {
                var v = rental.Verifications.FirstOrDefault(x => x.CheckType == VerificationCheck.BeforeRent);
                if (v != null && !string.IsNullOrEmpty(v.VerificationCode)) code = v.VerificationCode;
            }
            else if (phase == TransferPhase.Return && toRole == TransferActorType.Expert)
            {
                var v = rental.Verifications.FirstOrDefault(x => x.CheckType == VerificationCheck.AfterReturn);
                if (v != null && !string.IsNullOrEmpty(v.VerificationCode)) code = v.VerificationCode;
            }
        }

        return new RentalTransfer
        {
            RentalId = rental.Id,
            FromActorType = fromRole,
            FromActorId = fromId,
            ToActorType = toRole,
            ToActorId = toId,
            Sequence = sequence,
            Phase = phase,
            Status = TransferStatus.WaitingForCode,
            VerificationCode = code
        };
    }
}

public record VerifyTransferResponse(bool Success, string? Error);

public record GenerateExpertToOwnerTransfersCommand(Guid RentalId, DeliveryMethod Method) : IRequest<bool>;

public class GenerateExpertToOwnerTransfersCommandHandler : IRequestHandler<GenerateExpertToOwnerTransfersCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public GenerateExpertToOwnerTransfersCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(GenerateExpertToOwnerTransfersCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null || rental.CurrentPossession != ItemPossession.Expert) return false;

        // Check if transfers from Expert already exist in the Return phase
        var existingTransfers = await _context.RentalTransfers
            .AnyAsync(t => t.RentalId == rental.Id && t.Phase == TransferPhase.Return && t.FromActorType == TransferActorType.Expert, ct);
            
        if (existingTransfers) return false;

        bool hasDelivery = request.Method == DeliveryMethod.DeliveryService;
        var transfers = new List<RentalTransfer>();
        
        int seq = await _context.RentalTransfers.Where(t => t.RentalId == rental.Id).Select(t => (int?)t.Sequence).MaxAsync(ct) ?? 0;
        seq++;

        if (hasDelivery)
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Expert, TransferActorType.DeliveryAgent, TransferPhase.Return, rental.AssignedExpertId, null));
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.DeliveryAgent, TransferActorType.Owner, TransferPhase.Return, null, rental.Item.OwnerId));
        }
        else
        {
            transfers.Add(CreateTransfer(rental, seq++, TransferActorType.Expert, TransferActorType.Owner, TransferPhase.Return, rental.AssignedExpertId, rental.Item.OwnerId));
        }

        _context.RentalTransfers.AddRange(transfers);
        
        // Point CurrentTransferSequence to the first newly generated transfer
        rental.CurrentTransferSequence = transfers.Min(t => t.Sequence);
        
        await _context.SaveChangesAsync(ct);
        return true;
    }

    private RentalTransfer CreateTransfer(Rental rental, int sequence, TransferActorType fromRole, TransferActorType toRole, TransferPhase phase, long? fromId, long? toId)
    {
        var code = new Random().Next(100000, 999999).ToString();
        return new RentalTransfer
        {
            RentalId = rental.Id,
            Sequence = sequence,
            FromActorType = fromRole,
            ToActorType = toRole,
            Phase = phase,
            Status = TransferStatus.WaitingForCode,
            FromActorId = fromId,
            ToActorId = toId,
            VerificationCode = code
        };
    }
}

public record VerifyTransferCommand(Guid RentalId, string Code) : IRequest<VerifyTransferResponse>;

public class VerifyTransferCommandHandler : IRequestHandler<VerifyTransferCommand, VerifyTransferResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificationSender _notifier;
    private readonly ISender _sender;

    public VerifyTransferCommandHandler(IApplicationDbContext context, INotificationSender notifier, ISender sender)
    {
        _context = context;
        _notifier = notifier;
        _sender = sender;
    }

    public async Task<VerifyTransferResponse> Handle(VerifyTransferCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Transfers)
            .Include(r => r.Images)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new VerifyTransferResponse(false, "Rental not found.");

        var transfer = rental.Transfers.FirstOrDefault(t => t.Sequence == rental.CurrentTransferSequence);
        if (transfer == null) return new VerifyTransferResponse(false, "Transfer not active.");

        if (transfer.Status != TransferStatus.WaitingForCode)
            return new VerifyTransferResponse(false, "Transfer is not waiting for code.");

        if (transfer.ToActorType == TransferActorType.Renter && transfer.Phase == TransferPhase.Handoff)
        {
            var recentImage = rental.Images
                .Where(i => i.Type == RentalImageType.Handover)
                .OrderByDescending(i => i.CreatedAt)
                .FirstOrDefault();

            if (recentImage == null || (DateTime.UtcNow - recentImage.CreatedAt).TotalMinutes > 30)
            {
                return new VerifyTransferResponse(false, "errors.uploadRecentPhoto");
            }
        }
        else if (transfer.ToActorType == TransferActorType.Owner && transfer.Phase == TransferPhase.Return)
        {
            var recentImage = rental.Images
                .Where(i => i.Type == RentalImageType.Return)
                .OrderByDescending(i => i.CreatedAt)
                .FirstOrDefault();

            if (recentImage == null || (DateTime.UtcNow - recentImage.CreatedAt).TotalMinutes > 30)
            {
                return new VerifyTransferResponse(false, "errors.uploadRecentPhoto");
            }
        }

        if (transfer.VerificationCode != request.Code?.ToUpper())
        {
            return new VerifyTransferResponse(false, "errors.invalidVerificationCode");
        }

        transfer.Status = TransferStatus.Completed;
        transfer.CompletedAt = DateTime.UtcNow;
        transfer.UpdatedAt = DateTime.UtcNow;

        rental.CurrentTransferSequence++;

        // Update Possession
        switch (transfer.ToActorType)
        {
            case TransferActorType.Owner:
                rental.CurrentPossession = ItemPossession.Owner;
                break;
            case TransferActorType.Renter:
                rental.CurrentPossession = ItemPossession.Renter;
                break;
            case TransferActorType.Expert:
                rental.CurrentPossession = ItemPossession.Expert;
                break;
            case TransferActorType.DeliveryAgent:
                rental.CurrentPossession = ItemPossession.InTransit;
                break;
        }

        // If the renter hands over the item during the Return phase, set status to Returned (processing return)
        if (transfer.Phase == TransferPhase.Return && transfer.FromActorType == TransferActorType.Renter)
        {
            rental.Status = RentalStatus.Returned;
        }

        // If this was the last return sequence, complete the rental inline
        // (Cannot dispatch CompleteRentalCommand because it has owner-identity and photo guards
        //  that will reject calls when the current user is the renter verifying the code.)
        if (transfer.Phase == TransferPhase.Return && rental.CurrentPossession == ItemPossession.Owner)
        {
            var now = DateTime.UtcNow;
            rental.Status = RentalStatus.Completed;
            rental.ActualReturnDate = now;
            rental.UpdatedAt = now;
            rental.Item.Status = NewItemStatus.Available;
            rental.Item.UpdatedAt = now;

            // Late fee calculation
            var lateFee = 0m;
            var gracePeriod = TimeSpan.FromHours(24);
            if (now > rental.EndDate + gracePeriod)
            {
                var overdueDays = (decimal)Math.Ceiling((now - rental.EndDate).TotalDays);
                var dailyRate = rental.RentalPrice / (decimal)Math.Max(1, (rental.EndDate - rental.StartDate).TotalDays + 1);
                lateFee = Math.Round(overdueDays * dailyRate * 1.5m, 2);
            }
            rental.LateFee = lateFee;
            rental.DepositStatus = DepositStatus.Returned; // Default to returned (no damage in transfer flow)

            var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.Item.OwnerId, ct);
            var renter = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.UserId, ct);

            // -- Detect Early Return --
            decimal totalRentalDays = (decimal)Math.Max(1, (rental.EndDate.Date - rental.StartDate.Date).TotalDays + 1);
            decimal actualDaysPassed = (decimal)Math.Max(1, (now.Date - rental.StartDate.Date).TotalDays + 1);
            
            bool isEarlyReturn = actualDaysPassed < totalRentalDays;
            
            decimal usedRent = rental.RentalPrice;
            decimal unusedRent = 0m;
            decimal cancellationFee = 0m;
            decimal ownerCancellationCompensation = 0m;

            if (isEarlyReturn)
            {
                decimal dailyRate = rental.RentalPrice / totalRentalDays;
                usedRent = Math.Round(Math.Min(rental.RentalPrice, actualDaysPassed * dailyRate), 2);
                unusedRent = rental.RentalPrice - usedRent;
                
                var cancellationFeeSetting = await _context.SystemSettings.FirstOrDefaultAsync(s => s.Key == "CancellationFee", ct);
                if (cancellationFeeSetting != null && decimal.TryParse(cancellationFeeSetting.Value, out var parsedFee))
                    cancellationFee = parsedFee;
                else
                    cancellationFee = 500m;
                    
                ownerCancellationCompensation = Math.Round(cancellationFee * 0.85m, 2);
            }

            // Release escrow for wallet payments
            var payment = await _context.Payments.FirstOrDefaultAsync(
                p => p.OrderId == rental.OrderId && p.Method == PaymentMethod.Wallet && p.Status == PaymentStatus.Success, ct);

            if (payment != null && renter != null)
            {
                decimal renterExpertFeeShare = rental.RenterWantsExpertReview ? (rental.OwnerWantsExpertReview ? 50m : 100m) : 0m;

                // Deduct DepositAmount and ExpertFee from PendingBalance so we can refund them properly
                decimal heldRenterPending = rental.DepositAmount + (!rental.IsExpertPaid ? renterExpertFeeShare : 0m);
                renter.PendingBalance -= heldRenterPending;

                // Refund expert fee if not used
                if (!rental.IsExpertPaid && renterExpertFeeShare > 0)
                {
                    renter.WalletBalance += renterExpertFeeShare;
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renter.Id,
                        Amount = renterExpertFeeShare,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Expert Review Escrow refunded for rental {rental.Id}",
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }
                
                // Refund deposit immediately to renter's available balance
                if (rental.DepositAmount > 0)
                {
                    renter.WalletBalance += rental.DepositAmount;
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renter.Id,
                        Amount = rental.DepositAmount,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Deposit returned for rental {rental.Id}",
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });

                    await _notifier.SendToUserAsync(
                        renter.Id,
                        "Deposit Returned",
                        $"Your deposit of {rental.DepositAmount:C} has been returned to your wallet.",
                        "wallet", "/wallet", ct,
                        "إرجاع التأمين",
                        $"تم إرجاع تأمينك بقيمة {rental.DepositAmount:C} إلى محفظتك."
                    );
                }
            }

            if (owner != null && renter != null)
            {
                var penaltyToOwner = rental.DepositStatus == DepositStatus.Forfeited ? rental.DepositAmount * 0.8m : 0m;
                var grandTotalExtra = lateFee + penaltyToOwner;

                // --- PHASE 3: PLATFORM COMMISSION ---
                var platformCommissionPercent = rental.PlatformCommissionPercent / 100m;
                var platformCommissionAmount = Math.Round(usedRent * platformCommissionPercent, 2);
                
                decimal ownerExpertFeeShare = rental.OwnerWantsExpertReview ? (rental.RenterWantsExpertReview ? 50m : 100m) : 0m;

                var ownerRentPayout = usedRent - platformCommissionAmount;
                var totalOwnerPayout = ownerRentPayout + ownerCancellationCompensation;

                // 1. Revert the initial hold on Owner's PendingBalance (created at confirmation)
                owner.PendingBalance -= rental.RentalPrice + (!rental.IsExpertPaid ? ownerExpertFeeShare : 0m);

                // 2. Pay the owner their net earnings to Available Balance immediately
                owner.WalletBalance += totalOwnerPayout;

                string earningsDesc = isEarlyReturn 
                    ? $"Earnings for {usedRent:C} used rent + cancellation compensation for '{rental.Item.TitleEn}' (Rental ID: {rental.Id}). Commission deducted: {platformCommissionAmount:C}."
                    : $"Earnings for rental '{rental.Item.TitleEn}' (Rental ID: {rental.Id}). Commission deducted: {platformCommissionAmount:C}.";

                _context.WalletTransactions.Add(new WalletTransaction {
                    UserId = owner.Id,
                    Amount = totalOwnerPayout,
                    Type = TransactionType.RentalEarnings,
                    Description = earningsDesc,
                    RelatedRentalId = rental.Id,
                    IsPending = false,
                    CreatedAt = DateTimeOffset.UtcNow
                });

                // 3. Refund unused rent to Renter
                if (isEarlyReturn && unusedRent > 0)
                {
                    renter.WalletBalance += unusedRent;
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renter.Id,
                        Amount = unusedRent,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Refund for unused rent days on early return of rental {rental.Id}",
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                    
                    if (cancellationFee > 0)
                    {
                        renter.WalletBalance -= cancellationFee;
                        _context.WalletTransactions.Add(new WalletTransaction
                        {
                            UserId = renter.Id,
                            Amount = -cancellationFee,
                            Type = TransactionType.Penalty,
                            Description = $"Early return cancellation fee for rental {rental.Id}",
                            RelatedRentalId = rental.Id,
                            CreatedAt = DateTimeOffset.UtcNow
                        });
                    }
                }

                // If expert was NOT paid, refund the owner their expert fee share
                if (!rental.IsExpertPaid && ownerExpertFeeShare > 0)
                {
                    owner.WalletBalance += ownerExpertFeeShare;
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = owner.Id,
                        Amount = ownerExpertFeeShare,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Expert Review Escrow refunded for rental {rental.Id}",
                        RelatedRentalId = rental.Id,
                        IsPending = false,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }

                if (grandTotalExtra > 0)
                {
                    owner.PendingBalance += grandTotalExtra;
                    _context.WalletTransactions.Add(new WalletTransaction {
                        UserId = owner.Id,
                        Amount = grandTotalExtra,
                        Type = TransactionType.PendingEarnings,
                        Description = $"Pending extra income (Late fee/Penalty) for '{rental.Item.TitleEn}' (Rental ID: {rental.Id})",
                        RelatedRentalId = rental.Id,
                        IsPending = true,
                        ReleaseDate = DateTimeOffset.UtcNow.AddDays(14),
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                    
                    renter.WalletBalance -= lateFee;
                }
            }

            // Completion notifications
            await _notifier.SendToUserAsync(
                rental.UserId,
                "Rental Completed",
                $"Your rental for '{rental.Item.TitleEn}' is complete. The item has been returned.",
                "rental", $"/rentals/{rental.Id}", ct,
                "اكتمل الإيجار",
                $"اكتمل إيجار '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'. تم إرجاع المنتج."
            );
            await _notifier.SendToUserAsync(
                rental.Item.OwnerId,
                "Rental Completed",
                $"The rental for '{rental.Item.TitleEn}' is complete. The item has been returned to you.",
                "rental", $"/rentals/{rental.Id}", ct,
                "اكتمل الإيجار",
                $"اكتمل إيجار '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'. تم إرجاع المنتج إليك."
            );
        }
        else if (transfer.Phase == TransferPhase.Handoff && rental.CurrentPossession == ItemPossession.Renter)
        {
            rental.Status = RentalStatus.Active;
            
            // Shift start dates if they are late
            var duration = rental.EndDate - rental.StartDate;
            rental.StartDate = DateTime.UtcNow;
            rental.EndDate = rental.StartDate + duration;
        }

        // Notify both parties that the transfer was verified
        var titleEn = transfer.Phase == TransferPhase.Handoff ? "Handoff Verified" : "Return Verified";
        var msgEn = transfer.Phase == TransferPhase.Handoff 
            ? $"The handoff for '{rental.Item.TitleEn}' has been verified. The rental is now active."
            : $"The return for '{rental.Item.TitleEn}' has been verified.";

        var titleAr = transfer.Phase == TransferPhase.Handoff ? "تم توثيق التسليم" : "تم توثيق الإرجاع";
        var msgAr = transfer.Phase == TransferPhase.Handoff 
            ? $"تم توثيق تسليم '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'. الإيجار الآن نشط."
            : $"تم توثيق إرجاع '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'.";

        await _notifier.SendToUserAsync(rental.UserId, titleEn, msgEn, "transfer", $"/rentals/{rental.Id}", ct, titleAr, msgAr);
        if (rental.Item.OwnerId != rental.UserId)
        {
            await _notifier.SendToUserAsync(rental.Item.OwnerId, titleEn, msgEn, "transfer", $"/rentals/{rental.Id}", ct, titleAr, msgAr);
        }

        await _context.SaveChangesAsync(ct);
        return new VerifyTransferResponse(true, null);
    }
}
