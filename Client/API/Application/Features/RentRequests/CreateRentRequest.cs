using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record CreateRentRequestCommand(
    long RentableItemId,
    DateOnly StartDate,
    DateOnly EndDate,
    string? Message,
    bool IsDeliveryRequested,
    string? DeliveryAddress
) : IRequest<CreateRentRequestResponse>;

public record CreateRentRequestResponse(
    bool Success,
    string? Message,
    long? RequestId
);

public class CreateRentRequestCommandValidator : AbstractValidator<CreateRentRequestCommand>
{
    public CreateRentRequestCommandValidator()
    {
        RuleFor(x => x.RentableItemId)
            .GreaterThan(0).WithMessage("Invalid item ID.");

        RuleFor(x => x.StartDate)
            .GreaterThanOrEqualTo(DateOnly.FromDateTime(DateTime.Today))
            .WithMessage("Start date must be today or later.");

        RuleFor(x => x.EndDate)
            .GreaterThan(x => x.StartDate)
            .WithMessage("End date must be after start date.");

        RuleFor(x => x.Message)
            .MaximumLength(1000).WithMessage("Message must not exceed 1000 characters.");

        RuleFor(x => x.DeliveryAddress)
            .NotEmpty().When(x => x.IsDeliveryRequested)
            .WithMessage("Delivery address is required when delivery is requested.")
            .MaximumLength(500).WithMessage("Delivery address must not exceed 500 characters.");
    }
}

public class CreateRentRequestCommandHandler : IRequestHandler<CreateRentRequestCommand, CreateRentRequestResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notificationSender;

    public CreateRentRequestCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notificationSender)
    {
        _context = context;
        _currentUser = currentUser;
        _notificationSender = notificationSender;
    }

    public async Task<CreateRentRequestResponse> Handle(CreateRentRequestCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new CreateRentRequestResponse(false, "User not authenticated.", null);
        }

        var item = await _context.RentableItems
            .FirstOrDefaultAsync(r => r.Id == request.RentableItemId, cancellationToken);

        if (item == null)
        {
            return new CreateRentRequestResponse(false, "Item not found.", null);
        }

        if (item.Status != ItemStatus.Available)
        {
            return new CreateRentRequestResponse(false, "Item is not available for rent.", null);
        }

        if (item.OwnerId == _currentUser.Id.Value)
        {
            return new CreateRentRequestResponse(false, "You cannot rent your own item.", null);
        }

        // Calculate total days
        var totalDays = request.EndDate.DayNumber - request.StartDate.DayNumber + 1;

        if (totalDays < item.MinRentalDays)
        {
            return new CreateRentRequestResponse(false, $"Minimum rental period is {item.MinRentalDays} days.", null);
        }

        if (item.MaxRentalDays.HasValue && totalDays > item.MaxRentalDays.Value)
        {
            return new CreateRentRequestResponse(false, $"Maximum rental period is {item.MaxRentalDays.Value} days.", null);
        }

        // Check for overlapping requests
        var hasOverlap = await _context.RentRequests
            .AnyAsync(r =>
                r.RentableItemId == request.RentableItemId &&
                (r.Status == RentRequestStatus.Approved || r.Status == RentRequestStatus.Active) &&
                r.StartDate <= request.EndDate &&
                r.EndDate >= request.StartDate,
                cancellationToken);

        if (hasOverlap)
        {
            return new CreateRentRequestResponse(false, "The item is already booked for the selected dates.", null);
        }

        // Calculate pricing
        var dailyRate = item.PricePerDay;
        var totalAmount = dailyRate * totalDays;
        var deliveryFee = request.IsDeliveryRequested && item.IsAvailableForDelivery ? item.DeliveryFee : null;
        var grandTotal = totalAmount + (item.SecurityDeposit ?? 0) + (deliveryFee ?? 0);

        var rentRequest = new RentRequest
        {
            RentableItemId = request.RentableItemId,
            RenterId = _currentUser.Id.Value,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            TotalDays = totalDays,
            DailyRate = dailyRate,
            TotalAmount = totalAmount,
            SecurityDeposit = item.SecurityDeposit,
            DeliveryFee = deliveryFee,
            GrandTotal = grandTotal,
            Status = RentRequestStatus.Pending,
            Message = request.Message,
            IsDeliveryRequested = request.IsDeliveryRequested,
            DeliveryAddress = request.DeliveryAddress
        };

        _context.RentRequests.Add(rentRequest);
        await _context.SaveChangesAsync(cancellationToken);

        // Send notification to the item owner
        await _notificationSender.SendToUserAsync(
            item.OwnerId,
            "New Rental Request",
            $"You have a new rental request for {item.TitleEn}.",
            "rental",
            $"/rental-requests/{rentRequest.Id}",
            cancellationToken,
            titleAr: "طلب إيجار جديد",
            messageAr: $"لديك طلب إيجار جديد للمنتج {(!string.IsNullOrWhiteSpace(item.TitleAr) ? item.TitleAr : item.TitleEn)}."
        );

        return new CreateRentRequestResponse(true, "Rent request submitted successfully.", rentRequest.Id);
    }
}
