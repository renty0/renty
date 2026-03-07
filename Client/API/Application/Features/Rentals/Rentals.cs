using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Rentals;

// ── Shared DTO ────────────────────────────────────────────────────────────────

public record RentalListDto(
    Guid Id,
    string ItemTitle,
    string? ItemImage,
    DateTime StartDate,
    DateTime EndDate,
    decimal RentalPrice,
    string Status,
    string DepositStatus
);

public record RentalDetailDto(
    Guid Id,
    Guid ItemId,
    string ItemTitle,
    string? ItemImage,
    string OwnerFirstName,
    string? OwnerCity,
    DateTime StartDate,
    DateTime EndDate,
    DateTime? ActualReturnDate,
    decimal RentalPrice,
    decimal DepositAmount,
    decimal LateFee,
    string Status,
    string DepositStatus,
    string? Notes,
    DateTime CreatedAt,
    bool HasReview
);

// ── CREATE RENTAL ─────────────────────────────────────────────────────────────

public record CreateRentalCommand(
    Guid ItemId,
    DateTime StartDate,
    DateTime EndDate,
    string PricingType = "daily"
) : IRequest<CreateRentalResponse>;

public record CreateRentalResponse(bool Success, string? Error, Guid? RentalId, Guid? OrderId,
    decimal? RentalPrice, decimal? DepositAmount, string Status = "pending");

public class CreateRentalCommandValidator : AbstractValidator<CreateRentalCommand>
{
    public CreateRentalCommandValidator()
    {
        RuleFor(x => x.ItemId).NotEmpty();
        RuleFor(x => x.StartDate).NotEmpty();
        RuleFor(x => x.EndDate).GreaterThan(x => x.StartDate)
            .WithMessage("end_date must be after start_date.");
        RuleFor(x => x.PricingType)
            .Must(t => t == "daily" || t == "weekly" || t == "monthly")
            .WithMessage("pricingType must be daily, weekly, or monthly.");
    }
}

public class CreateRentalCommandHandler : IRequestHandler<CreateRentalCommand, CreateRentalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CreateRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreateRentalResponse> Handle(CreateRentalCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateRentalResponse(false, "Unauthorized.", null, null, null, null);

        var item = await _context.Items
            .Include(i => i.Pricing)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null)
            return new CreateRentalResponse(false, "Item not found.", null, null, null, null);

        if (item.Status != NewItemStatus.Available)
            return new CreateRentalResponse(false, "Item is not available.", null, null, null, null);

        // Self-rent check (DB trigger also enforces this)
        if (item.OwnerId == _currentUser.Id.Value)
            return new CreateRentalResponse(false, "A user cannot rent their own item.", null, null, null, null);

        var pricing = item.Pricing.FirstOrDefault(p => p.PricingType == request.PricingType);
        if (pricing == null)
            return new CreateRentalResponse(false, $"No {request.PricingType} pricing available for this item.", null, null, null, null);

        // Calculate duration and rental price
        var days = (decimal)(request.EndDate - request.StartDate).TotalDays;
        decimal rentalPrice = request.PricingType switch
        {
            "weekly"  => pricing.Price * Math.Ceiling(days / 7),
            "monthly" => pricing.Price * Math.Ceiling(days / 30),
            _         => pricing.Price * Math.Ceiling(days)
        };

        // Create order first
        var order = new Order
        {
            UserId = _currentUser.Id.Value,
            TotalAmount = rentalPrice + item.DefaultDeposit,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.Orders.Add(order);

        var rental = new Rental
        {
            UserId = _currentUser.Id.Value,
            ItemId = request.ItemId,
            OrderId = order.Id,
            RentalPrice = rentalPrice,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            Status = RentalStatus.Pending,
            DepositAmount = item.DefaultDeposit,
            DepositStatus = DepositStatus.Held,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.Rentals.Add(rental);

        // Log interaction
        _context.UserInteractions.Add(new UserInteraction
        {
            UserId = _currentUser.Id.Value,
            ItemId = request.ItemId,
            Action = InteractionAction.Rent,
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);

        return new CreateRentalResponse(true, null, rental.Id, order.Id, rental.RentalPrice, rental.DepositAmount);
    }
}

// ── GET RENTALS ───────────────────────────────────────────────────────────────

public record GetRentalsQuery(string? Status = null, int Page = 1, int Limit = 20) : IRequest<GetRentalsResponse>;
public record GetRentalsResponse(List<RentalListDto> Rentals, int Total, int Page, int Pages);

public class GetRentalsQueryHandler : IRequestHandler<GetRentalsQuery, GetRentalsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetRentalsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetRentalsResponse> Handle(GetRentalsQuery request, CancellationToken ct)
    {
        var query = _context.Rentals
            .Where(r => r.UserId == _currentUser.Id!.Value)
            .AsQueryable();

        if (!string.IsNullOrEmpty(request.Status) && Enum.TryParse<RentalStatus>(request.Status, true, out var status))
            query = query.Where(r => r.Status == status);

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var rentals = await query
            .OrderByDescending(r => r.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(r => new RentalListDto(
                r.Id,
                r.Item.TitleEn,
                r.Item.Images.Where(i => i.IsPrimary).Select(i => i.Image.StoragePath).FirstOrDefault()
                    ?? r.Item.Images.Select(i => i.Image.StoragePath).FirstOrDefault(),
                r.StartDate, r.EndDate, r.RentalPrice,
                r.Status.ToString(),
                r.DepositStatus.ToString()
            ))
            .ToListAsync(ct);

        return new GetRentalsResponse(rentals, total, request.Page, pages);
    }
}

// ── GET RENTAL BY ID ──────────────────────────────────────────────────────────

public record GetRentalByIdQuery(Guid RentalId) : IRequest<GetRentalByIdResponse>;
public record GetRentalByIdResponse(bool Found, string? Error, RentalDetailDto? Rental);

public class GetRentalByIdQueryHandler : IRequestHandler<GetRentalByIdQuery, GetRentalByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetRentalByIdQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetRentalByIdResponse> Handle(GetRentalByIdQuery request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item).ThenInclude(i => i.Images)
            .Include(r => r.Item).ThenInclude(i => i.Owner)
            .Include(r => r.Reviews)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new GetRentalByIdResponse(false, "Rental not found.", null);

        // Auth: renter or item owner
        if (rental.UserId != _currentUser.Id!.Value && rental.Item.OwnerId != _currentUser.Id!.Value)
            return new GetRentalByIdResponse(false, "Forbidden.", null);

        var dto = new RentalDetailDto(
            rental.Id, rental.ItemId, rental.Item.TitleEn,
            rental.Item.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath ?? rental.Item.Images.FirstOrDefault()?.Image?.StoragePath,
            rental.Item.Owner.FirstName, rental.Item.Owner.City,
            rental.StartDate, rental.EndDate, rental.ActualReturnDate,
            rental.RentalPrice, rental.DepositAmount, rental.LateFee,
            rental.Status.ToString(), rental.DepositStatus.ToString(),
            rental.Notes, rental.CreatedAt,
            rental.Reviews.Any()
        );

        return new GetRentalByIdResponse(true, null, dto);
    }
}

// ── CONFIRM RENTAL ────────────────────────────────────────────────────────────

public record ConfirmRentalCommand(Guid RentalId) : IRequest<RentalActionResponse>;
public record RentalActionResponse(bool Success, string? Error, string? Status);

public class ConfirmRentalCommandHandler : IRequestHandler<ConfirmRentalCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public ConfirmRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RentalActionResponse> Handle(ConfirmRentalCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        if (rental.Item.OwnerId != _currentUser.Id!.Value)
            return new RentalActionResponse(false, "Only the item owner can confirm a rental.", null);
        if (rental.Status != RentalStatus.Pending)
            return new RentalActionResponse(false, "Rental must be in pending status to confirm.", null);

        rental.Status = RentalStatus.Confirmed;
        rental.UpdatedAt = DateTime.UtcNow;

        // Notify renter
        _context.Notifications.Add(new Notification
        {
            UserId = rental.UserId,
            Title = "Rental Confirmed",
            Message = $"Your rental request for '{rental.Item.TitleEn}' has been confirmed by the owner.",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);
        return new RentalActionResponse(true, null, rental.Status.ToString());
    }
}

// ── ACTIVATE RENTAL ───────────────────────────────────────────────────────────

public record ActivateRentalCommand(Guid RentalId) : IRequest<RentalActionResponse>;

public class ActivateRentalCommandHandler : IRequestHandler<ActivateRentalCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;

    public ActivateRentalCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<RentalActionResponse> Handle(ActivateRentalCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        if (rental.Status != RentalStatus.Confirmed)
            return new RentalActionResponse(false, "Rental must be confirmed before activation.", null);

        // Set statuses
        rental.Status = RentalStatus.Active;
        rental.UpdatedAt = DateTime.UtcNow;
        rental.Item.Status = NewItemStatus.Rented;
        rental.Item.UpdatedAt = DateTime.UtcNow;

        // Simulated fraud check — in production: call external AI/ML service
        // Placeholder: derive a simple heuristic risk score
        var riskScore = 0.05; // safe baseline
        var decision = "safe";
        var indicators = new List<string>();

        // Example heuristics (real ML model would replace this)
        var recentRentals = await _context.Rentals
            .CountAsync(r => r.UserId == rental.UserId && r.CreatedAt >= DateTime.UtcNow.AddDays(-7), ct);
        if (recentRentals > 5) { riskScore += 0.3; indicators.Add("rental_spike"); }

        var avgReview = await _context.Reviews
            .Where(r => r.ReviewerId == rental.UserId)
            .AverageAsync(r => (double?)((double)r.Rating), ct) ?? 5.0;
        if (avgReview < 2.5) { riskScore += 0.3; indicators.Add("low_reviews"); }

        if (riskScore >= 0.5) decision = "flagged";
        else if (riskScore >= 0.8) decision = "blocked";

        _context.FraudLogs.Add(new FraudLog
        {
            UserId = rental.UserId,
            RiskScore = riskScore,
            Decision = decision,
            Reason = indicators.Any() ? string.Join(", ", indicators) : "Passed standard checks",
            FraudIndicators = indicators.Any() ? System.Text.Json.JsonSerializer.Serialize(indicators) : null,
            CreatedAt = DateTime.UtcNow
        });

        // Alert admins when flagged (admin panel will surface this via /admin/fraud)
        if (decision == "flagged" || decision == "blocked")
        {
            _context.Notifications.Add(new Notification
            {
                UserId = rental.UserId,
                Title = "⚠️ High Risk User Detected",
                Message = $"User {rental.UserId} scored {riskScore:F2} risk ({decision}). Indicators: {string.Join(", ", indicators)}",
                CreatedAt = DateTime.UtcNow
            });
        }


        await _context.SaveChangesAsync(ct);
        return new RentalActionResponse(true, null, rental.Status.ToString());
    }
}


// ── COMPLETE RENTAL ───────────────────────────────────────────────────────────

public record CompleteRentalCommand(Guid RentalId, bool Damaged = false) : IRequest<CompleteRentalResponse>;
public record CompleteRentalResponse(bool Success, string? Error, Guid? RentalId, string? Status, decimal? LateFee, string? DepositStatus);

public class CompleteRentalCommandHandler : IRequestHandler<CompleteRentalCommand, CompleteRentalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CompleteRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CompleteRentalResponse> Handle(CompleteRentalCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new CompleteRentalResponse(false, "Rental not found.", null, null, null, null);
        if (rental.Item.OwnerId != _currentUser.Id!.Value)
            return new CompleteRentalResponse(false, "Only the item owner can complete a rental.", null, null, null, null);
        if (rental.Status != RentalStatus.Active && rental.Status != RentalStatus.Overdue)
            return new CompleteRentalResponse(false, "Rental must be active or overdue to complete.", null, null, null, null);

        var now = DateTime.UtcNow;
        rental.ActualReturnDate = now;
        rental.Status = RentalStatus.Completed;
        rental.UpdatedAt = now;
        rental.Item.Status = NewItemStatus.Available;
        rental.Item.UpdatedAt = now;

        // Late fee: 10% of daily rate per overdue day (simple rule)
        if (now > rental.EndDate)
        {
            var overdueDays = (decimal)(now - rental.EndDate).TotalDays;
            rental.LateFee = Math.Round(overdueDays * (rental.RentalPrice / (decimal)(rental.EndDate - rental.StartDate).TotalDays) * 0.1m, 2);
        }

        rental.DepositStatus = request.Damaged ? DepositStatus.Forfeited : DepositStatus.Returned;

        // Notify renter
        _context.Notifications.Add(new Notification
        {
            UserId = rental.UserId,
            Title = "Rental Completed",
            Message = rental.LateFee > 0
                ? $"Your rental for '{rental.Item.TitleEn}' is complete. Late fee: {rental.LateFee:C}."
                : $"Your rental for '{rental.Item.TitleEn}' is complete. Thank you!",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);
        return new CompleteRentalResponse(true, null, rental.Id, rental.Status.ToString(), rental.LateFee, rental.DepositStatus.ToString());
    }
}

// ── CANCEL RENTAL ─────────────────────────────────────────────────────────────

public record CancelRentalCommand(Guid RentalId) : IRequest<RentalActionResponse>;

public class CancelRentalCommandHandler : IRequestHandler<CancelRentalCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CancelRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RentalActionResponse> Handle(CancelRentalCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        if (rental.UserId != _currentUser.Id!.Value)
            return new RentalActionResponse(false, "Only the renter can cancel.", null);
        if (rental.Status != RentalStatus.Pending && rental.Status != RentalStatus.Confirmed)
            return new RentalActionResponse(false, "Can only cancel pending or confirmed rentals.", null);

        rental.Status = RentalStatus.Cancelled;
        rental.UpdatedAt = DateTime.UtcNow;

        // If item was marked rented, restore it
        if (rental.Item.Status == NewItemStatus.Rented)
        {
            rental.Item.Status = NewItemStatus.Available;
            rental.Item.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync(ct);
        return new RentalActionResponse(true, null, "Rental cancelled");
    }
}
