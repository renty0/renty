using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Disputes;

public record OpenDisputeCommand(
    Guid RentalId,
    string ReasonType,
    string Description,
    List<string>? MediaUrls = null
) : IRequest<OpenDisputeResponse>;

public record OpenDisputeResponse(bool Success, string? Error);

public class OpenDisputeCommandValidator : AbstractValidator<OpenDisputeCommand>
{
    public OpenDisputeCommandValidator()
    {
        RuleFor(x => x.RentalId).NotEmpty();
        RuleFor(x => x.ReasonType).NotEmpty();
        RuleFor(x => x.Description).NotEmpty().MinimumLength(10);
        RuleFor(x => x.MediaUrls).NotEmpty().WithMessage("At least one photo must be uploaded when opening a dispute.");
    }
}

public class OpenDisputeCommandHandler : IRequestHandler<OpenDisputeCommand, OpenDisputeResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;
    private readonly IRoleService _roleService;

    public OpenDisputeCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier, IRoleService roleService)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
        _roleService = roleService;
    }

    public async Task<OpenDisputeResponse> Handle(OpenDisputeCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new OpenDisputeResponse(false, "Unauthorized.");

        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new OpenDisputeResponse(false, "Rental not found.");

        if (rental.UserId != _currentUser.Id.Value && rental.Item.OwnerId != _currentUser.Id.Value)
            return new OpenDisputeResponse(false, "Forbidden.");

        if (rental.Status == RentalStatus.Disputed)
            return new OpenDisputeResponse(false, "Rental is already disputed.");

        // Update rental status
        rental.Status = RentalStatus.Disputed;

        // Create Support Ticket
        var ticket = new SupportTicket
        {
            UserId = _currentUser.Id.Value,
            Type = SupportTicketType.Rental,
            Status = SupportTicketStatus.Open,
            RelatedRentalId = request.RentalId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.SupportTickets.Add(ticket);

        // Add Initial Message
        _context.SupportMessages.Add(new SupportMessage
        {
            TicketId = ticket.Id,
            SenderId = _currentUser.Id.Value,
            Message = $"**Reason:** {request.ReasonType}\n\n**Description:**\n{request.Description}",
            CreatedAt = DateTime.UtcNow
        });

        if (request.MediaUrls != null && request.MediaUrls.Any())
        {
            foreach (var url in request.MediaUrls)
            {
                _context.SupportMessages.Add(new SupportMessage
                {
                    TicketId = ticket.Id,
                    SenderId = _currentUser.Id.Value,
                    MediaUrl = url,
                    MessageType = Domain.Enums.MessageType.Image,
                    CreatedAt = DateTime.UtcNow
                });
            }
        }

        // Add Event
        _context.SupportTicketEvents.Add(new SupportTicketEvent
        {
            TicketId = ticket.Id,
            ActorId = _currentUser.Id.Value,
            EventType = "Created",
            Details = "Dispute ticket created by user.",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);

        var sender = await _context.Users.FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);
        var userName = sender?.FirstName ?? "A user";

        // Notify the other party
        var otherPartyId = rental.UserId == _currentUser.Id.Value ? rental.Item.OwnerId : rental.UserId;
        await _notifier.SendToUserAsync(
            otherPartyId,
            "Rental Disputed",
            $"{userName} has opened a dispute on your rental for '{rental.Item.TitleEn}'.",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "إيجار متنازع عليه",
            messageAr: $"فتح {userName} نزاعًا على إيجارك للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'."
        );

        return new OpenDisputeResponse(true, null);
    }
}


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
