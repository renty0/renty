using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record RespondToRentRequestCommand(
    long RequestId,
    bool Approve,
    string? Response,
    string? PickupInstructions
) : IRequest<RespondToRentRequestResponse>;

public record RespondToRentRequestResponse(
    bool Success,
    string? Message
);

public class RespondToRentRequestCommandValidator : AbstractValidator<RespondToRentRequestCommand>
{
    public RespondToRentRequestCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");

        RuleFor(x => x.Response)
            .MaximumLength(1000).WithMessage("Response must not exceed 1000 characters.");

        RuleFor(x => x.PickupInstructions)
            .MaximumLength(1000).WithMessage("Pickup instructions must not exceed 1000 characters.");
    }
}

public class RespondToRentRequestCommandHandler : IRequestHandler<RespondToRentRequestCommand, RespondToRentRequestResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notificationSender;

    public RespondToRentRequestCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notificationSender)
    {
        _context = context;
        _currentUser = currentUser;
        _notificationSender = notificationSender;
    }

    public async Task<RespondToRentRequestResponse> Handle(RespondToRentRequestCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new RespondToRentRequestResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new RespondToRentRequestResponse(false, "Request not found.");
        }

        if (rentRequest.RentableItem.OwnerId != _currentUser.Id.Value)
        {
            return new RespondToRentRequestResponse(false, "You can only respond to requests for your own items.");
        }

        if (rentRequest.Status != RentRequestStatus.Pending)
        {
            return new RespondToRentRequestResponse(false, "This request has already been responded to.");
        }

        rentRequest.Status = request.Approve ? RentRequestStatus.Approved : RentRequestStatus.Rejected;
        rentRequest.OwnerResponse = request.Response;
        rentRequest.RespondedAt = DateTimeOffset.UtcNow;

        if (request.Approve)
        {
            rentRequest.PickupInstructions = request.PickupInstructions;
        }

        await _context.SaveChangesAsync(cancellationToken);

        // Send notification to the renter
        var notificationTitle = request.Approve ? "Rental Request Approved" : "Rental Request Rejected";
        var notificationMessage = request.Approve
            ? $"Your rental request for {rentRequest.RentableItem.TitleEn} has been approved."
            : $"Your rental request for {rentRequest.RentableItem.TitleEn} has been rejected.";

        await _notificationSender.SendToUserAsync(
            rentRequest.RenterId,
            notificationTitle,
            notificationMessage,
            "rental",
            $"/rental-requests/{rentRequest.Id}",
            cancellationToken
        );

        return new RespondToRentRequestResponse(
            true,
            request.Approve ? "Request approved successfully." : "Request rejected."
        );
    }
}
