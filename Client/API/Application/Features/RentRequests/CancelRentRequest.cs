using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record CancelRentRequestCommand(
    long RequestId,
    string? CancellationReason
) : IRequest<CancelRentRequestResponse>;

public record CancelRentRequestResponse(
    bool Success,
    string? Message
);

public class CancelRentRequestCommandValidator : AbstractValidator<CancelRentRequestCommand>
{
    public CancelRentRequestCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");

        RuleFor(x => x.CancellationReason)
            .MaximumLength(500).WithMessage("Cancellation reason must not exceed 500 characters.");
    }
}

public class CancelRentRequestCommandHandler : IRequestHandler<CancelRentRequestCommand, CancelRentRequestResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notificationSender;

    public CancelRentRequestCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notificationSender)
    {
        _context = context;
        _currentUser = currentUser;
        _notificationSender = notificationSender;
    }

    public async Task<CancelRentRequestResponse> Handle(CancelRentRequestCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new CancelRentRequestResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new CancelRentRequestResponse(false, "Request not found.");
        }

        if (rentRequest.RenterId != _currentUser.Id.Value)
        {
            return new CancelRentRequestResponse(false, "You can only cancel your own requests.");
        }

        if (rentRequest.Status != RentRequestStatus.Pending && rentRequest.Status != RentRequestStatus.Approved)
        {
            return new CancelRentRequestResponse(false, "This request cannot be cancelled.");
        }

        rentRequest.Status = RentRequestStatus.Cancelled;
        rentRequest.CancellationReason = request.CancellationReason;
        rentRequest.CancelledAt = DateTimeOffset.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        // Send notification to the item owner
        await _notificationSender.SendToUserAsync(
            rentRequest.RentableItem.OwnerId,
            "Rental Request Cancelled",
            $"The rental request for {rentRequest.RentableItem.TitleEn} has been cancelled by the renter.",
            "rental",
            $"/rental-requests/{rentRequest.Id}",
            cancellationToken,
            titleAr: "تم إلغاء طلب الإيجار",
            messageAr: $"تم إلغاء طلب الإيجار لـ '{(!string.IsNullOrWhiteSpace(rentRequest.RentableItem.TitleAr) ? rentRequest.RentableItem.TitleAr : rentRequest.RentableItem.TitleEn)}' من قبل المستأجر."
        );

        return new CancelRentRequestResponse(true, "Request cancelled successfully.");
    }
}
