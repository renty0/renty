using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentableItems;

public record CreateRentableItemCommand(
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
    int? SubcategoryId,
    List<CreateRentableItemImageCommand>? Images
) : IRequest<CreateRentableItemResponse>;

public record CreateRentableItemImageCommand(
    string ImageUrl,
    string? ThumbnailUrl,
    string? AltText,
    int DisplayOrder,
    bool IsPrimary
);

public record CreateRentableItemResponse(
    bool Success,
    string? Message,
    long? ItemId
);

public class CreateRentableItemCommandValidator : AbstractValidator<CreateRentableItemCommand>
{
    public CreateRentableItemCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Title is required.")
            .MaximumLength(200).WithMessage("Title must not exceed 200 characters.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required.")
            .MaximumLength(4000).WithMessage("Description must not exceed 4000 characters.");

        RuleFor(x => x.ShortDescription)
            .MaximumLength(500).WithMessage("Short description must not exceed 500 characters.");

        RuleFor(x => x.PricePerDay)
            .GreaterThan(0).WithMessage("Price per day must be greater than 0.");

        RuleFor(x => x.PricePerWeek)
            .GreaterThan(0).When(x => x.PricePerWeek.HasValue)
            .WithMessage("Price per week must be greater than 0.");

        RuleFor(x => x.PricePerMonth)
            .GreaterThan(0).When(x => x.PricePerMonth.HasValue)
            .WithMessage("Price per month must be greater than 0.");

        RuleFor(x => x.SecurityDeposit)
            .GreaterThanOrEqualTo(0).When(x => x.SecurityDeposit.HasValue)
            .WithMessage("Security deposit must be non-negative.");

        RuleFor(x => x.MinRentalDays)
            .GreaterThan(0).WithMessage("Minimum rental days must be at least 1.");

        RuleFor(x => x.MaxRentalDays)
            .GreaterThanOrEqualTo(x => x.MinRentalDays).When(x => x.MaxRentalDays.HasValue)
            .WithMessage("Maximum rental days must be greater than or equal to minimum rental days.");

        RuleFor(x => x.DeliveryFee)
            .GreaterThanOrEqualTo(0).When(x => x.DeliveryFee.HasValue)
            .WithMessage("Delivery fee must be non-negative.");
    }
}

public class CreateRentableItemCommandHandler : IRequestHandler<CreateRentableItemCommand, CreateRentableItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CreateRentableItemCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreateRentableItemResponse> Handle(CreateRentableItemCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new CreateRentableItemResponse(false, "User not authenticated.", null);
        }

        if (request.CategoryId.HasValue)
        {
            var categoryExists = await _context.ProductCategories
                .AnyAsync(c => c.Id == request.CategoryId.Value, cancellationToken);
            if (!categoryExists)
            {
                return new CreateRentableItemResponse(false, "Category not found.", null);
            }
        }

        if (request.SubcategoryId.HasValue)
        {
            var subcategoryExists = await _context.ProductSubcategories
                .AnyAsync(s => s.Id == request.SubcategoryId.Value, cancellationToken);
            if (!subcategoryExists)
            {
                return new CreateRentableItemResponse(false, "Subcategory not found.", null);
            }
        }

        var item = new RentableItem
        {
            Title = request.Title,
            Description = request.Description,
            ShortDescription = request.ShortDescription,
            PricePerDay = request.PricePerDay,
            PricePerWeek = request.PricePerWeek,
            PricePerMonth = request.PricePerMonth,
            SecurityDeposit = request.SecurityDeposit,
            Location = request.Location,
            City = request.City,
            Country = request.Country,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            MinRentalDays = request.MinRentalDays,
            MaxRentalDays = request.MaxRentalDays,
            IsAvailableForDelivery = request.IsAvailableForDelivery,
            DeliveryFee = request.DeliveryFee,
            Terms = request.Terms,
            CancellationPolicy = request.CancellationPolicy,
            CategoryId = request.CategoryId,
            SubcategoryId = request.SubcategoryId,
            OwnerId = _currentUser.Id.Value,
            Status = ItemStatus.Draft
        };

        if (request.Images != null && request.Images.Any())
        {
            foreach (var imageCommand in request.Images)
            {
                item.Images.Add(new RentableItemImage
                {
                    ImageUrl = imageCommand.ImageUrl,
                    ThumbnailUrl = imageCommand.ThumbnailUrl,
                    AltText = imageCommand.AltText,
                    DisplayOrder = imageCommand.DisplayOrder,
                    IsPrimary = imageCommand.IsPrimary
                });
            }
        }

        _context.RentableItems.Add(item);
        await _context.SaveChangesAsync(cancellationToken);

        return new CreateRentableItemResponse(true, "Item created successfully.", item.Id);
    }
}
