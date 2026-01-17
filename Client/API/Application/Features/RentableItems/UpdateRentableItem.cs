using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentableItems;

public record UpdateRentableItemCommand(
    long Id,
    string Title,
    string Description,
    string? ShortDescription,
    decimal PricePerDay,
    decimal? PricePerWeek,
    decimal? PricePerMonth,
    decimal? SecurityDeposit,
    string? Location,
    string? City,
    string? Country,
    double? Latitude,
    double? Longitude,
    int MinRentalDays,
    int? MaxRentalDays,
    bool IsAvailableForDelivery,
    decimal? DeliveryFee,
    string? Terms,
    string? CancellationPolicy,
    int? CategoryId,
    int? SubcategoryId
) : IRequest<UpdateRentableItemResponse>;

public record UpdateRentableItemResponse(
    bool Success,
    string? Message
);

public class UpdateRentableItemCommandValidator : AbstractValidator<UpdateRentableItemCommand>
{
    public UpdateRentableItemCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid item ID.");

        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Title is required.")
            .MaximumLength(200).WithMessage("Title must not exceed 200 characters.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required.")
            .MaximumLength(4000).WithMessage("Description must not exceed 4000 characters.");

        RuleFor(x => x.PricePerDay)
            .GreaterThan(0).WithMessage("Price per day must be greater than 0.");

        RuleFor(x => x.MinRentalDays)
            .GreaterThan(0).WithMessage("Minimum rental days must be at least 1.");
    }
}

public class UpdateRentableItemCommandHandler : IRequestHandler<UpdateRentableItemCommand, UpdateRentableItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public UpdateRentableItemCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<UpdateRentableItemResponse> Handle(UpdateRentableItemCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new UpdateRentableItemResponse(false, "User not authenticated.");
        }

        var item = await _context.RentableItems
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (item == null)
        {
            return new UpdateRentableItemResponse(false, "Item not found.");
        }

        if (item.OwnerId != _currentUser.Id.Value)
        {
            return new UpdateRentableItemResponse(false, "You can only update your own items.");
        }

        item.Title = request.Title;
        item.Description = request.Description;
        item.ShortDescription = request.ShortDescription;
        item.PricePerDay = request.PricePerDay;
        item.PricePerWeek = request.PricePerWeek;
        item.PricePerMonth = request.PricePerMonth;
        item.SecurityDeposit = request.SecurityDeposit;
        item.Location = request.Location;
        item.City = request.City;
        item.Country = request.Country;
        item.Latitude = request.Latitude;
        item.Longitude = request.Longitude;
        item.MinRentalDays = request.MinRentalDays;
        item.MaxRentalDays = request.MaxRentalDays;
        item.IsAvailableForDelivery = request.IsAvailableForDelivery;
        item.DeliveryFee = request.DeliveryFee;
        item.Terms = request.Terms;
        item.CancellationPolicy = request.CancellationPolicy;
        item.CategoryId = request.CategoryId;
        item.SubcategoryId = request.SubcategoryId;

        await _context.SaveChangesAsync(cancellationToken);

        return new UpdateRentableItemResponse(true, "Item updated successfully.");
    }
}
