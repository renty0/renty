using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Rentals;


public record RentalListDto(
    Guid Id,
    string ItemTitle,
    string? ItemImageUrl,
    long OwnerId,
    string OwnerFirstName,
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
    string? ItemImageUrl,
    long OwnerId,
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
    string? HandoffCode,
    bool IsHandoffVerified,
    DateTime CreatedAt,
    bool HasReview,
    List<string> HandoverImageUrls,
    List<string> ReturnImageUrls
);


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

        var user = await _context.Users.FindAsync(new object[] { _currentUser.Id.Value }, ct);
        if (user == null || !user.EmailConfirmed)
        {
            return new CreateRentalResponse(false, "Please confirm your email address before renting items.", null, null, null, null);
        }

        var item = await _context.Items
            .Include(i => i.Pricing)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null)
            return new CreateRentalResponse(false, "Item not found.", null, null, null, null);

        if (item.Status != NewItemStatus.Available)
            return new CreateRentalResponse(false, "Item is not available.", null, null, null, null);

        if (item.OwnerId == _currentUser.Id.Value)
            return new CreateRentalResponse(false, "A user cannot rent their own item.", null, null, null, null);

        var pricing = item.Pricing.FirstOrDefault(p => p.PricingType == request.PricingType);
        if (pricing == null)
            return new CreateRentalResponse(false, $"No {request.PricingType} pricing available for this item.", null, null, null, null);

        var days = (decimal)(request.EndDate - request.StartDate).TotalDays;
        decimal rentalPrice = request.PricingType switch
        {
            "weekly"  => pricing.Price * Math.Ceiling(days / 7),
            "monthly" => pricing.Price * Math.Ceiling(days / 30),
            _         => pricing.Price * Math.Ceiling(days)
        };

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
            HandoffCode = Guid.NewGuid().ToString("N")[..6].ToUpper(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.Rentals.Add(rental);

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


public record GetRentalsQuery(string? Status = null, int Page = 1, int Limit = 20) : IRequest<GetRentalsResponse>;
public record GetRentalsResponse(List<RentalListDto> Rentals, int Total, int Page, int Pages);
 
public class GetRentalsQueryHandler : IRequestHandler<GetRentalsQuery, GetRentalsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

    public GetRentalsQueryHandler(IApplicationDbContext context, IUser currentUser, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetRentalsResponse> Handle(GetRentalsQuery request, CancellationToken ct)
    {
        var requestPath = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestPath != null ? $"{requestPath.Scheme}://{requestPath.Host}" : "";

        var query = _context.Rentals
            .Where(r => r.UserId == _currentUser.Id!.Value || r.Item.OwnerId == _currentUser.Id!.Value)
            .AsQueryable();

        if (!string.IsNullOrEmpty(request.Status) && Enum.TryParse<RentalStatus>(request.Status, true, out var status))
            query = query.Where(r => r.Status == status);

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var rentals = await query
            .OrderByDescending(r => r.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Include(r => r.Item).ThenInclude(i => i.Images).ThenInclude(ii => ii.Image)
            .Include(r => r.Item).ThenInclude(i => i.Owner)
            .ToListAsync(ct);

        var dtos = rentals.Select(r => {
            var storagePath = r.Item.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath ?? r.Item.Images.FirstOrDefault()?.Image?.StoragePath;
            var fullUrl = !string.IsNullOrEmpty(storagePath) ? $"{baseUrl}/{storagePath}" : null;
            return new RentalListDto(
                r.Id,
                r.Item.TitleEn,
                fullUrl,
                r.Item.OwnerId,
                r.Item.Owner.FirstName,
                r.StartDate, r.EndDate, r.RentalPrice,
                r.Status.ToString(),
                r.DepositStatus.ToString()
            );
        }).ToList();

        return new GetRentalsResponse(dtos, total, request.Page, pages);
    }
}


public record GetRentalByIdQuery(Guid RentalId) : IRequest<GetRentalByIdResponse>;
public record GetRentalByIdResponse(bool Found, string? Error, RentalDetailDto? Rental);

public class GetRentalByIdQueryHandler : IRequestHandler<GetRentalByIdQuery, GetRentalByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

    public GetRentalByIdQueryHandler(IApplicationDbContext context, IUser currentUser, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetRentalByIdResponse> Handle(GetRentalByIdQuery request, CancellationToken ct)
    {
        var requestPath = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestPath != null ? $"{requestPath.Scheme}://{requestPath.Host}" : "";

        var rental = await _context.Rentals
            .Include(r => r.Item).ThenInclude(i => i.Images).ThenInclude(ii => ii.Image)
            .Include(r => r.Item).ThenInclude(i => i.Owner)
            .Include(r => r.Reviews)
            .Include(r => r.Images).ThenInclude(ri => ri.Image)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new GetRentalByIdResponse(false, "Rental not found.", null);

        if (rental.UserId != _currentUser.Id!.Value && rental.Item.OwnerId != _currentUser.Id!.Value)
            return new GetRentalByIdResponse(false, "Forbidden.", null);

        var itemStoragePath = rental.Item.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath ?? rental.Item.Images.FirstOrDefault()?.Image?.StoragePath;
        var itemFullUrl = !string.IsNullOrEmpty(itemStoragePath) ? $"{baseUrl}/{itemStoragePath}" : null;

        var dto = new RentalDetailDto(
            rental.Id, rental.ItemId, rental.Item.TitleEn,
            itemFullUrl,
            rental.Item.OwnerId,
            rental.Item.Owner.FirstName, rental.Item.Owner.City,
            rental.StartDate, rental.EndDate, rental.ActualReturnDate,
            rental.RentalPrice, rental.DepositAmount, rental.LateFee,
            rental.Status.ToString(), rental.DepositStatus.ToString(),
            rental.Notes,
            rental.HandoffCode,
            rental.IsHandoffVerified,
            rental.CreatedAt,
            rental.Reviews.Any(),
            rental.Images.Where(i => i.Type == RentalImageType.Handover).Select(i => $"{baseUrl}/{i.Image.StoragePath}").ToList(),
            rental.Images.Where(i => i.Type == RentalImageType.Return).Select(i => $"{baseUrl}/{i.Image.StoragePath}").ToList()
        );

        return new GetRentalByIdResponse(true, null, dto);
    }
}


public record ConfirmRentalCommand(Guid RentalId) : IRequest<RentalActionResponse>;
public record RentalActionResponse(bool Success, string? Error, string? Status);

public class ConfirmRentalCommandHandler : IRequestHandler<ConfirmRentalCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public ConfirmRentalCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
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

        await _context.SaveChangesAsync(ct);

        await _notifier.SendToUserAsync(
            rental.UserId,
            "Rental Confirmed",
            $"Your rental request for '{rental.Item.TitleEn}' has been confirmed by the owner.",
            "rental",
            $"/my-rentals/{rental.Id}",
            ct);

        return new RentalActionResponse(true, null, rental.Status.ToString());
    }
}


public record VerifyHandoffCommand(Guid RentalId, string Code) : IRequest<RentalActionResponse>;

public class VerifyHandoffCommandHandler : IRequestHandler<VerifyHandoffCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public VerifyHandoffCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<RentalActionResponse> Handle(VerifyHandoffCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Images)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        
        if (rental.Item.OwnerId != _currentUser.Id!.Value)
            return new RentalActionResponse(false, "Only the item owner can verify the handoff code.", null);

        if (rental.Status != RentalStatus.Confirmed)
            return new RentalActionResponse(false, "Rental must be confirmed before handoff.", null);

        if (rental.HandoffCode != request.Code?.ToUpper())
            return new RentalActionResponse(false, "Invalid handoff code.", null);

        if (!rental.Images.Any(i => i.Type == RentalImageType.Handover))
            return new RentalActionResponse(false, "Handover photos are required before verification.", null);

        rental.IsHandoffVerified = true;
        rental.Status = RentalStatus.Active;
        rental.UpdatedAt = DateTime.UtcNow;
        rental.Item.Status = NewItemStatus.Rented;

        await _context.SaveChangesAsync(ct);

        await _notifier.SendToUserAsync(
            rental.UserId,
            "Rental Started",
            $"Your rental for '{rental.Item.TitleEn}' is now active. Enjoy!",
            "rental",
            $"/my-rentals/{rental.Id}",
            ct);

        return new RentalActionResponse(true, null, rental.Status.ToString());
    }
}



public record CompleteRentalCommand(Guid RentalId, bool Damaged = false) : IRequest<CompleteRentalResponse>;
public record CompleteRentalResponse(bool Success, string? Error, Guid? RentalId, string? Status, decimal? LateFee, string? DepositStatus);

public class CompleteRentalCommandHandler : IRequestHandler<CompleteRentalCommand, CompleteRentalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public CompleteRentalCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<CompleteRentalResponse> Handle(CompleteRentalCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.User)
            .Include(r => r.Images)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new CompleteRentalResponse(false, "Rental not found.", null, null, null, null);
        if (rental.Item.OwnerId != _currentUser.Id!.Value)
            return new CompleteRentalResponse(false, "Only the item owner can complete a rental.", null, null, null, null);
        if (rental.Status != RentalStatus.Active && rental.Status != RentalStatus.Overdue)
            return new CompleteRentalResponse(false, "Rental must be active or overdue to complete.", null, null, null, null);

        if (!rental.Images.Any(i => i.Type == RentalImageType.Return))
            return new CompleteRentalResponse(false, "Return photos are required before completion.", null, null, null, null);

        var now = DateTime.UtcNow;
        rental.ActualReturnDate = now;
        rental.Status = RentalStatus.Completed;
        rental.UpdatedAt = now;
        rental.Item.Status = NewItemStatus.Available;
        rental.Item.UpdatedAt = now;

        var lateFee = 0m;
        if (now > rental.EndDate)
        {
            var overdueDays = (decimal)Math.Ceiling((now - rental.EndDate).TotalDays);
            var dailyRate = rental.RentalPrice / (decimal)Math.Max(1, (rental.EndDate - rental.StartDate).TotalDays);
            lateFee = Math.Round(overdueDays * dailyRate * 1.5m, 2); 
        }

        rental.DepositStatus = request.Damaged ? DepositStatus.Forfeited : DepositStatus.Returned;

        var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.Item.OwnerId, ct);
        var renter = rental.User;

        if (owner != null && renter != null)
        {
            var totalToOwner = rental.RentalPrice + lateFee;
            owner.WalletBalance += totalToOwner;
            _context.WalletTransactions.Add(new WalletTransaction {
                UserId = owner.Id,
                Amount = totalToOwner,
                Type = TransactionType.RentalIncome,
                Description = $"Rental income for '{rental.Item.TitleEn}' (Rental ID: {rental.Id})",
                RelatedRentalId = rental.Id,
                CreatedAt = DateTimeOffset.UtcNow
            });

            if (rental.DepositStatus == DepositStatus.Forfeited)
            {
                var penaltyToOwner = rental.DepositAmount * 0.8m;
                owner.WalletBalance += penaltyToOwner;
                _context.WalletTransactions.Add(new WalletTransaction {
                    UserId = owner.Id,
                    Amount = penaltyToOwner,
                    Type = TransactionType.Adjustment,
                    Description = $"Damage compensation for '{rental.Item.TitleEn}' (Rental ID: {rental.Id})",
                    RelatedRentalId = rental.Id,
                    CreatedAt = DateTimeOffset.UtcNow
                });
            }
        }

        await _context.SaveChangesAsync(ct);

        // Notify renter
        var renterMsg = lateFee > 0
            ? $"Your rental for '{rental.Item.TitleEn}' is complete. Late fee: {lateFee:C}. Deposit: {rental.DepositStatus}."
            : $"Your rental for '{rental.Item.TitleEn}' is complete. Thank you!";
        await _notifier.SendToUserAsync(rental.UserId, "Rental Completed", renterMsg, "rental", $"/my-rentals/{rental.Id}", ct);

        // Notify favorited users
        var favUserIds = await _context.Favorites
            .Where(f => f.ItemId == rental.ItemId && f.UserId != rental.Item.OwnerId)
            .Select(f => f.UserId)
            .ToListAsync(ct);

        // Notify reminded users
        var reminderUserIds = await _context.ItemReminders
            .Where(r => r.ItemId == rental.ItemId)
            .Select(r => r.UserId)
            .ToListAsync(ct);

        var itemUrl = $"/marketplace/{rental.ItemId}";
        var itemTitle = rental.Item.TitleEn;

        var allNotifyIds = favUserIds.Union(reminderUserIds).Distinct()
            .Where(uid => uid != rental.UserId && uid != rental.Item.OwnerId)
            .ToList();

        if (allNotifyIds.Any())
        {
            await _notifier.SendToUsersAsync(
                allNotifyIds,
                "Item Available",
                $"'{itemTitle}' is now available for rent again!",
                "item",
                itemUrl,
                ct);
        }

        // Remove reminders for this item (already notified)
        var reminders = await _context.ItemReminders.Where(r => r.ItemId == rental.ItemId).ToListAsync(ct);
        if (reminders.Any())
        {
            _context.ItemReminders.RemoveRange(reminders);
            await _context.SaveChangesAsync(ct);
        }

        return new CompleteRentalResponse(true, null, rental.Id, rental.Status.ToString(), rental.LateFee, rental.DepositStatus.ToString());
    }
}


public record CancelRentalCommand(Guid RentalId) : IRequest<RentalActionResponse>;

public class CancelRentalCommandHandler : IRequestHandler<CancelRentalCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public CancelRentalCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
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

        if (rental.Item.Status == NewItemStatus.Rented)
        {
            rental.Item.Status = NewItemStatus.Available;
            rental.Item.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync(ct);

        await _notifier.SendToUserAsync(
            rental.Item.OwnerId,
            "Rental Cancelled",
            $"The rental request for '{rental.Item.TitleEn}' was cancelled by the renter.",
            "rental",
            $"/my-rentals/{rental.Id}",
            ct);

        return new RentalActionResponse(true, null, "Rental cancelled");
    }
}


/// <summary>Body-only DTO for the POST /rentals/:id/photos endpoint.</summary>
public record UploadRentalPhotosBody(List<Guid> ImageIds, RentalImageType Type);

public record UploadRentalPhotosCommand(Guid RentalId, List<Guid> ImageIds, RentalImageType Type) : IRequest<bool>;

public class UploadRentalPhotosCommandHandler : IRequestHandler<UploadRentalPhotosCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public UploadRentalPhotosCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(UploadRentalPhotosCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return false;

        if (rental.UserId != _currentUser.Id!.Value && rental.Item.OwnerId != _currentUser.Id!.Value)
            return false;

        foreach (var id in request.ImageIds)
        {
            if (!_context.RentalImages.Any(ri => ri.RentalId == rental.Id && ri.ImageId == id))
            {
                _context.RentalImages.Add(new RentalImage
                {
                    RentalId = rental.Id,
                    ImageId = id,
                    Type = request.Type
                });
            }
        }

        await _context.SaveChangesAsync(ct);
        return true;
    }
}
