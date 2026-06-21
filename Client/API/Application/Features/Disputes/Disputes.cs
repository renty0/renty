using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Disputes;


public record ResolveDisputeCommand(
    Guid RentalId,
    string ResolutionDecision,
    decimal OwnerCompensation,
    decimal RenterRefund,
    string Reason
) : IRequest<ResolveDisputeResponse>;

public record ResolveDisputeResponse(bool Success, string? Error);

public class ResolveDisputeCommandValidator : AbstractValidator<ResolveDisputeCommand>
{
    public ResolveDisputeCommandValidator()
    {
        RuleFor(x => x.RentalId).NotEmpty();
        RuleFor(x => x.ResolutionDecision).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty();
    }
}

public class ResolveDisputeCommandHandler : IRequestHandler<ResolveDisputeCommand, ResolveDisputeResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public ResolveDisputeCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<ResolveDisputeResponse> Handle(ResolveDisputeCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new ResolveDisputeResponse(false, "Rental not found.");
        
        var ownerUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.Item.OwnerId, ct);
        var renterUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.UserId, ct);

        if (ownerUser == null || renterUser == null)
            return new ResolveDisputeResponse(false, "Linked accounts not found.");

        if (request.OwnerCompensation + request.RenterRefund > rental.DepositAmount)
            return new ResolveDisputeResponse(false, "Total payouts cannot exceed the original deposit amount.");

        if (rental.DepositStatus == DepositStatus.Returned || rental.DepositStatus == DepositStatus.Forfeited)
            return new ResolveDisputeResponse(false, "Deposit for this rental has already been processed.");

        if (request.OwnerCompensation > 0)
        {
            ownerUser.WalletBalance += request.OwnerCompensation;
            _context.WalletTransactions.Add(new WalletTransaction
            {
                UserId = ownerUser.Id,
                Amount = request.OwnerCompensation,
                Type = TransactionType.Penalty, 
                Description = $"Dispute Resolution: Compensation for rental {rental.Id} - {request.Reason}",
                RelatedRentalId = rental.Id,
                CreatedAt = DateTimeOffset.UtcNow
            });
        }

        if (request.RenterRefund > 0)
        {
            renterUser.WalletBalance += request.RenterRefund;
            _context.WalletTransactions.Add(new WalletTransaction
            {
                UserId = renterUser.Id,
                Amount = request.RenterRefund,
                Type = TransactionType.Refund,
                Description = $"Dispute Resolution: Refund for rental {rental.Id} - {request.Reason}",
                RelatedRentalId = rental.Id,
                CreatedAt = DateTimeOffset.UtcNow
            });
        }

        rental.DepositStatus = request.ResolutionDecision == "refund_renter" ? DepositStatus.Returned : DepositStatus.Forfeited;
        
        await _context.SaveChangesAsync(ct);

        // Notify both parties
        await _notifier.SendToUserAsync(
            ownerUser.Id,
            "Dispute Resolved",
            $"The dispute for '{rental.Item.TitleEn}' has been resolved. Compensation: {request.OwnerCompensation:C}",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "تم حل النزاع",
            messageAr: $"تم حل النزاع للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'. التعويض: {request.OwnerCompensation:C}");

        await _notifier.SendToUserAsync(
            renterUser.Id,
            "Dispute Resolved",
            $"The dispute for '{rental.Item.TitleEn}' has been resolved. Refund: {request.RenterRefund:C}",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "تم حل النزاع",
            messageAr: $"تم حل النزاع للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'. الاسترداد: {request.RenterRefund:C}");

        return new ResolveDisputeResponse(true, null);
    }
}
