using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record UpdateRentRequestCommand(
    long RequestId,
    DateOnly? StartDate,
    DateOnly? EndDate,
    string? Message,
    bool? IsDeliveryRequested,
    string? DeliveryAddress
) : IRequest<UpdateRentRequestResponse>;

public record UpdateRentRequestResponse(
    bool Success,
    string? Message
);

public class UpdateRentRequestCommandValidator : AbstractValidator<UpdateRentRequestCommand>
{
    public UpdateRentRequestCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");

        RuleFor(x => x.StartDate)
            .GreaterThanOrEqualTo(DateOnly.FromDateTime(DateTime.Today))
            .When(x => x.StartDate.HasValue)
            .WithMessage("Start date must be today or later.");

        RuleFor(x => x.EndDate)
            .GreaterThan(x => x.StartDate)
            .When(x => x.StartDate.HasValue && x.EndDate.HasValue)
            .WithMessage("End date must be after start date.");

        RuleFor(x => x.Message)
            .MaximumLength(1000).WithMessage("Message must not exceed 1000 characters.");

        RuleFor(x => x.DeliveryAddress)
            .NotEmpty().When(x => x.IsDeliveryRequested == true)
            .WithMessage("Delivery address is required when delivery is requested.")
            .MaximumLength(500).WithMessage("Delivery address must not exceed 500 characters.");
    }
}

public class UpdateRentRequestCommandHandler : IRequestHandler<UpdateRentRequestCommand, UpdateRentRequestResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notificationSender;

    public UpdateRentRequestCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notificationSender)
    {
        _context = context;
        _currentUser = currentUser;
        _notificationSender = notificationSender;
    }

    public async Task<UpdateRentRequestResponse> Handle(UpdateRentRequestCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new UpdateRentRequestResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new UpdateRentRequestResponse(false, "Request not found.");
        }

        if (rentRequest.RenterId != _currentUser.Id.Value)
        {
            return new UpdateRentRequestResponse(false, "You can only modify your own requests.");
        }

        if (rentRequest.Status != RentRequestStatus.Pending)
        {
            return new UpdateRentRequestResponse(false, "This request cannot be modified.");
        }

        // Update fields if provided
        if (request.StartDate.HasValue)
        {
            rentRequest.StartDate = request.StartDate.Value;
        }

        if (request.EndDate.HasValue)
        {
            rentRequest.EndDate = request.EndDate.Value;
        }

        // Recalculate total days and pricing if dates changed
        if (request.StartDate.HasValue || request.EndDate.HasValue)
        {
            var totalDays = rentRequest.EndDate.DayNumber - rentRequest.StartDate.DayNumber + 1;

            if (totalDays < rentRequest.RentableItem.MinRentalDays)
            {
                return new UpdateRentRequestResponse(false, $"Minimum rental period is {rentRequest.RentableItem.MinRentalDays} days.");
            }

            if (rentRequest.RentableItem.MaxRentalDays.HasValue && totalDays > rentRequest.RentableItem.MaxRentalDays.Value)
            {
                return new UpdateRentRequestResponse(false, $"Maximum rental period is {rentRequest.RentableItem.MaxRentalDays.Value} days.");
            }

            // Check for overlapping requests
            var hasOverlap = await _context.RentRequests
                .AnyAsync(r =>
                    r.RentableItemId == rentRequest.RentableItemId &&
                    r.Id != rentRequest.Id &&
                    (r.Status == RentRequestStatus.Approved || r.Status == RentRequestStatus.Active) &&
                    r.StartDate <= rentRequest.EndDate &&
                    r.EndDate >= rentRequest.StartDate,
                    cancellationToken);

            if (hasOverlap)
            {
                return new UpdateRentRequestResponse(false, "The item is already booked for the selected dates.");
            }

            rentRequest.TotalDays = totalDays;
            rentRequest.TotalAmount = rentRequest.DailyRate * totalDays;
            var deliveryFee = request.IsDeliveryRequested == true && rentRequest.RentableItem.IsAvailableForDelivery 
                ? rentRequest.RentableItem.DeliveryFee 
                : null;
            rentRequest.DeliveryFee = deliveryFee;
            rentRequest.GrandTotal = rentRequest.TotalAmount + (rentRequest.SecurityDeposit ?? 0) + (deliveryFee ?? 0);
        }

        if (request.Message != null)
        {
            rentRequest.Message = request.Message;
        }

        if (request.IsDeliveryRequested.HasValue)
        {
            rentRequest.IsDeliveryRequested = request.IsDeliveryRequested.Value;
        }

        if (request.DeliveryAddress != null)
        {
            rentRequest.DeliveryAddress = request.DeliveryAddress;
        }

        await _context.SaveChangesAsync(cancellationToken);

        // Notify the item owner about the modification
        await _notificationSender.SendToUserAsync(
            rentRequest.RentableItem.OwnerId,
            "Rental Request Modified",
            $"The rental request for {rentRequest.RentableItem.TitleEn} has been modified by the renter.",
            "rental",
            $"/rental-requests/{rentRequest.Id}",
            cancellationToken,
            titleAr: "تم تعديل طلب الإيجار",
            messageAr: $"تم تعديل طلب إيجار {(!string.IsNullOrWhiteSpace(rentRequest.RentableItem.TitleAr) ? rentRequest.RentableItem.TitleAr : rentRequest.RentableItem.TitleEn)} من قبل المستأجر."
        );

        return new UpdateRentRequestResponse(true, "Rent request updated successfully.");
    }
}
