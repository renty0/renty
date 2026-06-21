using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record CompleteRentalCommand(long RequestId) : IRequest<CompleteRentalResponse>;

public record CompleteRentalResponse(
    bool Success,
    string? Message
);

public class CompleteRentalCommandValidator : AbstractValidator<CompleteRentalCommand>
{
    public CompleteRentalCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");
    }
}

public class CompleteRentalCommandHandler : IRequestHandler<CompleteRentalCommand, CompleteRentalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CompleteRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CompleteRentalResponse> Handle(CompleteRentalCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new CompleteRentalResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new CompleteRentalResponse(false, "Request not found.");
        }

        if (rentRequest.RentableItem.OwnerId != _currentUser.Id.Value)
        {
            return new CompleteRentalResponse(false, "You can only complete rentals for your own items.");
        }

        if (rentRequest.Status != RentRequestStatus.Active)
        {
            return new CompleteRentalResponse(false, "Only active rentals can be completed.");
        }

        var renter = await _context.Users.FirstOrDefaultAsync(u => u.Id == rentRequest.RenterId, cancellationToken);
        var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == rentRequest.RentableItem.OwnerId, cancellationToken);
        
        if (renter != null && owner != null)
        {
            // Refund the security deposit to the Renter's Available Balance from their Pending Balance
            if (rentRequest.SecurityDeposit > 0)
            {
                renter.PendingBalance -= rentRequest.SecurityDeposit.Value;
                renter.WalletBalance += rentRequest.SecurityDeposit.Value;
                
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    UserId = renter.Id,
                    Amount = rentRequest.SecurityDeposit.Value,
                    Type = TransactionType.EscrowRelease,
                    Description = $"Escrow release for completed rental {rentRequest.Id}",
                    CreatedAt = DateTimeOffset.UtcNow
                });
            }
        }

        rentRequest.Status = RentRequestStatus.Completed;
        rentRequest.RentableItem.Status = ItemStatus.Available;

        await _context.SaveChangesAsync(cancellationToken);

        return new CompleteRentalResponse(true, "Rental completed successfully.");
    }
}
