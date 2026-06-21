using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using Application.Common.Models;
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
    long RenterId,
    string RenterFirstName,
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
    bool RenterWantsExpertReview,
    bool OwnerWantsExpertReview,
    decimal ExpertReviewFee,
    long? AssignedExpertId,
    string? AssignedExpertName,
    List<RentalImageDto> HandoverImages,
    List<RentalImageDto> ReturnImages,
    List<RentalTransferDto> Transfers,
    List<VerificationDto> Verifications,
    string CurrentPossession,
    int CurrentTransferSequence,
    string? DeliveryMethodFromExpert
);

public record RentalImageDto(string Url, bool CanDelete);

public record RentalTransferDto(
    Guid Id,
    string Phase,
    int Sequence,
    string FromActorType,
    long? FromActorId,
    string ToActorType,
    long? ToActorId,
    string Status,
    string? VerificationCode,
    DateTime? CompletedAt,
    DateTime CreatedAt
);

public record CreateRentalCommand(
    Guid ItemId,
    DateTime StartDate,
    DateTime EndDate,
    string PricingType = "daily",
    string? Notes = null,
    bool RequestExpertReview = false,
    DeliveryMethod DeliveryMethod = DeliveryMethod.ByHand,
    DateTime? DesiredDeliveryDate = null
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
    private readonly Microsoft.AspNetCore.Identity.UserManager<ApplicationUser> _userManager;
    private readonly INotificationSender _notifier;

    public CreateRentalCommandHandler(
        IApplicationDbContext context, 
        IUser currentUser,
        Microsoft.AspNetCore.Identity.UserManager<ApplicationUser> userManager,
        INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _userManager = userManager;
        _notifier = notifier;
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

        var days = (decimal)(request.EndDate - request.StartDate).TotalDays + 1;
        decimal rentalPrice = request.PricingType switch
        {
            "weekly"  => pricing.Price * Math.Ceiling(days / 7),
            "monthly" => pricing.Price * Math.Ceiling(days / 30),
            _         => pricing.Price * Math.Ceiling(days)
        };

        var expertFee = request.RequestExpertReview ? 100m : 0m;
        var totalAmount = rentalPrice + item.DefaultDeposit + expertFee;

        if (user.WalletBalance < totalAmount)
        {
            return new CreateRentalResponse(false, "Insufficient balance. Please recharge your wallet.", null, null, null, null);
        }

        var order = new Order
        {
            UserId = _currentUser.Id.Value,
            TotalAmount = totalAmount,
            Status = OrderStatus.Paid,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.Orders.Add(order);

        // Escrow Hold (Separate conceptual buckets)
        user.WalletBalance -= totalAmount;
        user.PendingBalance += totalAmount;

        _context.WalletTransactions.Add(new WalletTransaction
        {
            UserId = user.Id,
            Amount = -rentalPrice,
            Type = TransactionType.EscrowHold,
            Description = $"Rental Escrow hold for rental order {order.Id}",
            IsPending = true,
            CreatedAt = DateTimeOffset.UtcNow
        });

        _context.WalletTransactions.Add(new WalletTransaction
        {
            UserId = user.Id,
            Amount = -item.DefaultDeposit,
            Type = TransactionType.EscrowHold,
            Description = $"Deposit Escrow hold for rental order {order.Id}",
            IsPending = true,
            CreatedAt = DateTimeOffset.UtcNow
        });

        if (expertFee > 0)
        {
            _context.WalletTransactions.Add(new WalletTransaction
            {
                UserId = user.Id,
                Amount = -expertFee,
                Type = TransactionType.EscrowHold,
                Description = $"Expert Escrow hold for rental order {order.Id}",
                IsPending = true,
                CreatedAt = DateTimeOffset.UtcNow
            });
        }

        // Add payment record
        var payment = new Payment
        {
            OrderId = order.Id,
            Amount = totalAmount,
            Method = PaymentMethod.Wallet,
            Status = PaymentStatus.Success,
            TransactionRef = Guid.NewGuid().ToString("N")[..16].ToUpper(),
            CreatedAt = DateTime.UtcNow
        };
        _context.Payments.Add(payment);

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
            Notes = request.Notes,
            RenterWantsExpertReview = request.RequestExpertReview,
            ExpertReviewFee = request.RequestExpertReview ? 100 : 0, // Flat fee
            DeliveryMethod = request.DeliveryMethod,
            DesiredDeliveryDate = request.DesiredDeliveryDate,
            CurrentPossession = ItemPossession.Owner,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        if (rental.RenterWantsExpertReview)
        {
            rental.Verifications.Add(new ItemVerification
            {
                ItemId = request.ItemId,
                CheckType = VerificationCheck.BeforeRent,
                Status = VerificationStatus.Pending,
                VerificationCode = new Random().Next(100000, 999999).ToString()
            });
        }
        _context.Rentals.Add(rental);

        _context.UserInteractions.Add(new UserInteraction
        {
            UserId = _currentUser.Id.Value,
            ItemId = request.ItemId,
            Action = InteractionAction.Rent,
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);

        // Send notification to the item owner
        await _notifier.SendToUserAsync(
            item.OwnerId,
            "New Rental Request",
            $"You have a new rental request for '{item.TitleEn}'.",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "طلب إيجار جديد",
            messageAr: $"لديك طلب إيجار جديد للمنتج '{(!string.IsNullOrWhiteSpace(item.TitleAr) ? item.TitleAr : item.TitleEn)}'."
        );

        if (rental.RenterWantsExpertReview)
        {
            var experts = await _userManager.GetUsersInRoleAsync("Expert");
            if (experts.Any())
            {
                var expertIds = experts.Select(e => e.Id).ToList();
                await _notifier.SendToUsersAsync(
                    expertIds,
                    "New Expert Task",
                    $"A new item verification has been requested for '{item.TitleEn}'.",
                    "verification",
                    "/expert/assigned",
                    ct,
                    titleAr: "مهمة خبير جديدة",
                    messageAr: $"تم طلب تحقق جديد للمنتج '{(!string.IsNullOrWhiteSpace(item.TitleAr) ? item.TitleAr : item.TitleEn)}'."
                );
            }
        }

        return new CreateRentalResponse(true, null, rental.Id, order.Id, rental.RentalPrice, rental.DepositAmount);
    }
}


public record GetRentalsQuery(string? Status = null, int Page = 1, int Limit = 20, string? Role = null) : IRequest<GetRentalsResponse>;
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

        var query = _context.Rentals.AsQueryable();

        if (request.Role?.ToLower() == "owner")
        {
            query = query.Where(r => r.Item.OwnerId == _currentUser.Id!.Value);
        }
        else if (request.Role?.ToLower() == "renter")
        {
            query = query.Where(r => r.UserId == _currentUser.Id!.Value);
        }
        else
        {
            query = query.Where(r => r.UserId == _currentUser.Id!.Value || r.Item.OwnerId == _currentUser.Id!.Value);
        }

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
            var fullUrl = !string.IsNullOrEmpty(storagePath) ? (storagePath.StartsWith("http") ? storagePath : $"{baseUrl.TrimEnd('/')}/{storagePath.Replace("\\\\", "/").TrimStart('/')}") : null;
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
            .Include(r => r.User)
            .Include(r => r.Reviews)
            .Include(r => r.Verifications).ThenInclude(v => v.Expert)
            .Include(r => r.Images).ThenInclude(ri => ri.Image)
            .Include(r => r.Transfers)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new GetRentalByIdResponse(false, "Rental not found.", null);

        if (rental.UserId != _currentUser.Id!.Value && rental.Item.OwnerId != _currentUser.Id!.Value)
            return new GetRentalByIdResponse(false, "Forbidden.", null);

        var itemStoragePath = rental.Item.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath ?? rental.Item.Images.FirstOrDefault()?.Image?.StoragePath;
        var itemFullUrl = !string.IsNullOrEmpty(itemStoragePath) ? (itemStoragePath.StartsWith("http") ? itemStoragePath : $"{baseUrl.TrimEnd('/')}/{itemStoragePath.Replace("\\\\", "/").TrimStart('/')}") : null;

        var dto = new RentalDetailDto(
            rental.Id, rental.ItemId, rental.Item.TitleEn,
            itemFullUrl,
            rental.Item.OwnerId,
            rental.Item.Owner.FirstName, rental.Item.Owner.City,
            rental.UserId,
            rental.User.FirstName,
            rental.StartDate, rental.EndDate, rental.ActualReturnDate,
            rental.RentalPrice, rental.DepositAmount, rental.LateFee,
            rental.Status.ToString(), rental.DepositStatus.ToString(),
            rental.Notes,
            rental.CreatedAt,
            rental.RenterWantsExpertReview,
            rental.OwnerWantsExpertReview,
            rental.ExpertReviewFee,
            rental.AssignedExpertId,
            rental.AssignedExpert?.FirstName,
            rental.Images.Where(i => i.Type == RentalImageType.Handover).Select(i => new RentalImageDto(
                i.Image.StoragePath.StartsWith("http") ? i.Image.StoragePath : $"{baseUrl.TrimEnd('/')}/{i.Image.StoragePath.Replace("\\\\", "/").TrimStart('/')}",
                i.Image.CreatedBy == _currentUser.Id
            )).ToList(),
            rental.Images.Where(i => i.Type == RentalImageType.Return).Select(i => new RentalImageDto(
                i.Image.StoragePath.StartsWith("http") ? i.Image.StoragePath : $"{baseUrl.TrimEnd('/')}/{i.Image.StoragePath.Replace("\\\\", "/").TrimStart('/')}",
                i.Image.CreatedBy == _currentUser.Id
            )).ToList(),
            rental.Transfers.OrderBy(t => t.Sequence).Select(t => new RentalTransferDto(
                t.Id, t.Phase.ToString(), t.Sequence, t.FromActorType.ToString(), t.FromActorId,
                t.ToActorType.ToString(), t.ToActorId, t.Status.ToString(), 
                t.VerificationCode, t.CompletedAt, t.CreatedAt
            )).ToList(),
            rental.Verifications.OrderByDescending(v => v.CreatedAt).Select(v => new VerificationDto(
                v.Id, v.CheckType.ToString(), v.Status.ToString(), v.Notes,
                v.Expert?.FirstName, v.CreatedAt, v.VerificationCode
            )).ToList(),
            rental.CurrentPossession.ToString(),
            rental.CurrentTransferSequence,
            rental.DeliveryMethodFromExpert?.ToString()
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
        if (!_currentUser.Id.HasValue)
            return new RentalActionResponse(false, "User session not found.", null);

        if (rental.Item.OwnerId != _currentUser.Id.Value)
            return new RentalActionResponse(false, "Only the item owner can confirm a rental.", null);
        if (rental.Status != RentalStatus.Pending)
            return new RentalActionResponse(false, "Rental must be in pending status to confirm.", null);

        rental.Status = RentalStatus.Confirmed;
        rental.Item.Status = NewItemStatus.Rented;
        rental.UpdatedAt = DateTime.UtcNow;

        var renter = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.UserId, ct);
        var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.Item.OwnerId, ct);
        var payment = await _context.Payments.FirstOrDefaultAsync(p => p.OrderId == rental.OrderId && p.Method == PaymentMethod.Wallet && p.Status == PaymentStatus.Success, ct);

        if (renter != null && owner != null && payment != null)
        {
            // At CreateRental, the FULL amount (RentalPrice + Deposit) was added to Renter's PendingBalance.
            // Now that the owner confirmed, we transfer the RentalPrice part to the Owner's PendingEarnings.
            // The DepositAmount stays in the Renter's PendingBalance.
            
            renter.PendingBalance -= rental.RentalPrice;
            owner.PendingBalance += rental.RentalPrice;

            _context.WalletTransactions.Add(new WalletTransaction {
                UserId = owner.Id,
                Amount = rental.RentalPrice,
                Type = TransactionType.PendingEarnings,
                Description = $"Pending rental income for '{rental.Item.TitleEn}' (Rental ID: {rental.Id})",
                RelatedRentalId = rental.Id,
                IsPending = true,
                ReleaseDate = DateTimeOffset.UtcNow.AddDays(14),
                CreatedAt = DateTimeOffset.UtcNow
            });
        }

        await _context.SaveChangesAsync(ct);

        await _notifier.SendToUserAsync(
            rental.UserId,
            "Rental Confirmed",
            $"Your rental request for '{rental.Item.TitleEn}' has been confirmed by the owner.",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "تأكيد الإيجار",
            messageAr: $"تم تأكيد طلب الإيجار الخاص بك للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}' من قبل المالك."
        );

        return new RentalActionResponse(true, null, rental.Status.ToString());
    }
}

public record SetHandoffMethodCommand(Guid RentalId, DeliveryMethod Method) : IRequest<RentalActionResponse>;

public class SetHandoffMethodCommandHandler : IRequestHandler<SetHandoffMethodCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly ISender _sender;

    public SetHandoffMethodCommandHandler(IApplicationDbContext context, IUser currentUser, ISender sender)
    {
        _context = context;
        _currentUser = currentUser;
        _sender = sender;
    }

    public async Task<RentalActionResponse> Handle(SetHandoffMethodCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Transfers)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        if (!_currentUser.Id.HasValue)
            return new RentalActionResponse(false, "User session not found.", null);

        if (rental.Item.OwnerId != _currentUser.Id.Value)
            return new RentalActionResponse(false, "Only the item owner can set the handoff method.", null);
            
        if (rental.Status != RentalStatus.Confirmed)
            return new RentalActionResponse(false, "Rental must be confirmed before setting handoff method.", null);

        if (rental.Transfers.Any())
            return new RentalActionResponse(false, "Handoff method already configured.", null);

        rental.DeliveryMethod = request.Method;
        rental.Status = RentalStatus.AwaitingPickup;
        rental.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(ct);
        
        // Generate handoff chain transfers based on owner's selected delivery method
        await _sender.Send(new Application.Features.Transfers.GenerateHandoffTransfersCommand(rental.Id, request.Method), ct);

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
        if (rental.Status != RentalStatus.Active && rental.Status != RentalStatus.Overdue && rental.Status != RentalStatus.Returned && rental.Status != RentalStatus.Cancelled)
            return new CompleteRentalResponse(false, "Rental must be active, overdue, returned, or cancelled to complete.", null, null, null, null);

        if (!rental.Images.Any(i => i.Type == RentalImageType.Return))
            return new CompleteRentalResponse(false, "Return photos are required before completion.", null, null, null, null);

        var now = DateTime.UtcNow;
        rental.ActualReturnDate = now;
        rental.Status = RentalStatus.Completed;
        rental.UpdatedAt = now;
        rental.Item.Status = NewItemStatus.Available;
        rental.Item.UpdatedAt = now;

        var lateFee = 0m;
        var gracePeriod = TimeSpan.FromHours(24);
        if (now > rental.EndDate + gracePeriod)
        {
            var overdueDays = (decimal)Math.Ceiling((now - rental.EndDate).TotalDays);
            var dailyRate = rental.RentalPrice / (decimal)Math.Max(1, (rental.EndDate - rental.StartDate).TotalDays + 1);
            lateFee = Math.Round(overdueDays * dailyRate * 1.5m, 2); 
        }
        rental.LateFee = lateFee;

        rental.DepositStatus = request.Damaged ? DepositStatus.Forfeited : DepositStatus.Returned;

        var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.Item.OwnerId, ct);
        var renter = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.UserId, ct);

        // -- Detect Early Return --
        var returnTransfer = await _context.RentalTransfers
            .Where(t => t.RentalId == rental.Id && t.Status == TransferStatus.Completed && t.ToActorType == TransferActorType.Owner)
            .OrderByDescending(t => t.CompletedAt)
            .FirstOrDefaultAsync(ct);
            
        DateTime actualReturnDate = returnTransfer?.CompletedAt ?? DateTime.UtcNow;
        decimal totalRentalDays = (decimal)Math.Max(1, (rental.EndDate.Date - rental.StartDate.Date).TotalDays + 1);
        decimal actualDaysPassed = (decimal)Math.Max(1, (actualReturnDate.Date - rental.StartDate.Date).TotalDays + 1);
        
        bool isEarlyReturn = actualDaysPassed < totalRentalDays;
        
        decimal usedRent = rental.RentalPrice;
        decimal unusedRent = 0m;
        decimal cancellationFee = 0m;
        decimal ownerCancellationCompensation = 0m;

        if (isEarlyReturn)
        {
            decimal dailyRate = rental.RentalPrice / totalRentalDays;
            usedRent = Math.Round(Math.Min(rental.RentalPrice, actualDaysPassed * dailyRate), 2);
            unusedRent = rental.RentalPrice - usedRent;
            
            var cancellationFeeSetting = await _context.SystemSettings.FirstOrDefaultAsync(s => s.Key == "CancellationFee", ct);
            if (cancellationFeeSetting != null && decimal.TryParse(cancellationFeeSetting.Value, out var parsedFee))
                cancellationFee = parsedFee;
            else
                cancellationFee = 500m;
                
            ownerCancellationCompensation = Math.Round(cancellationFee * 0.85m, 2);
        }

        // Release Escrow if Wallet payment
        var payment = await _context.Payments.FirstOrDefaultAsync(p => p.OrderId == rental.OrderId && p.Method == PaymentMethod.Wallet && p.Status == PaymentStatus.Success, ct);
        if (payment != null && renter != null)
        {
            decimal renterExpertFeeShare = rental.RenterWantsExpertReview ? (rental.OwnerWantsExpertReview ? 50m : 100m) : 0m;

            // The rental.RentalPrice was already deducted from PendingBalance at confirmation.
            // Deduct DepositAmount. If expert was NOT paid (e.g. no verification completed?), deduct their share here so we can refund it.
            decimal heldRenterPending = rental.DepositAmount + (!rental.IsExpertPaid ? renterExpertFeeShare : 0m);
            renter.PendingBalance -= heldRenterPending;

            // If the expert was NOT paid by the time the rental is completed, refund the expert fee share to the renter.
            if (!rental.IsExpertPaid && renterExpertFeeShare > 0)
            {
                renter.WalletBalance += renterExpertFeeShare;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    UserId = renter.Id,
                    Amount = renterExpertFeeShare,
                    Type = TransactionType.EscrowRelease,
                    Description = $"Expert Review Escrow refunded for rental {rental.Id}",
                    RelatedRentalId = rental.Id,
                    CreatedAt = DateTimeOffset.UtcNow
                });
            }
            
            // Refund deposit if returned
            if (rental.DepositStatus == DepositStatus.Returned && rental.DepositAmount > 0)
            {
                renter.WalletBalance += rental.DepositAmount;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    UserId = renter.Id,
                    Amount = rental.DepositAmount,
                    Type = TransactionType.EscrowRelease,
                    Description = $"Deposit returned for rental {rental.Id}",
                    RelatedRentalId = rental.Id,
                    CreatedAt = DateTimeOffset.UtcNow
                });

                await _notifier.SendToUserAsync(
                    renter.Id,
                    "Deposit Returned",
                    $"Your deposit of {rental.DepositAmount:C} has been returned to your wallet.",
                    "wallet",
                    "/wallet",
                    ct,
                    "إرجاع التأمين",
                    $"تم إرجاع تأمينك بقيمة {rental.DepositAmount:C} إلى محفظتك."
                );
            }
        }

        await _notifier.SendToUserAsync(renter.Id, "DEBUG LOG", $"owner is {(owner != null ? "NOT null" : "NULL")}, renter is {(renter != null ? "NOT null" : "NULL")}, isEarly: {isEarlyReturn}", "wallet", null, ct, "DEBUG", "DEBUG");

        if (owner != null && renter != null)
        {
            var penaltyToOwner = rental.DepositStatus == DepositStatus.Forfeited ? rental.DepositAmount * 0.8m : 0m;
            var grandTotalExtra = lateFee + penaltyToOwner;

            // --- PHASE 3: PLATFORM COMMISSION ---
            var platformCommissionPercent = rental.PlatformCommissionPercent / 100m;
            var platformCommissionAmount = Math.Round(usedRent * platformCommissionPercent, 2);
            
            decimal ownerExpertFeeShare = rental.OwnerWantsExpertReview ? (rental.RenterWantsExpertReview ? 50m : 100m) : 0m;

            var ownerRentPayout = usedRent - platformCommissionAmount;
            var totalOwnerPayout = ownerRentPayout + ownerCancellationCompensation;

            // 1. Revert the initial hold on Owner's PendingBalance (created at confirmation)
            // If expert was not paid, the Owner's pending balance still holds their expert fee share.
            owner.PendingBalance -= rental.RentalPrice + (!rental.IsExpertPaid ? ownerExpertFeeShare : 0m);

            // 2. Pay the owner their net earnings to Available Balance
            owner.WalletBalance += totalOwnerPayout;

            string earningsDesc = isEarlyReturn 
                ? $"Earnings for {usedRent:C} used rent + cancellation compensation for '{rental.Item.TitleEn}' (Rental ID: {rental.Id}). Commission deducted: {platformCommissionAmount:C}."
                : $"Earnings for rental '{rental.Item.TitleEn}' (Rental ID: {rental.Id}). Commission deducted: {platformCommissionAmount:C}.";

            _context.WalletTransactions.Add(new WalletTransaction {
                UserId = owner.Id,
                Amount = totalOwnerPayout,
                Type = TransactionType.RentalEarnings,
                Description = earningsDesc,
                RelatedRentalId = rental.Id,
                IsPending = false,
                CreatedAt = DateTimeOffset.UtcNow
            });

            // 3. Refund unused rent to Renter
            if (isEarlyReturn && unusedRent > 0)
            {
                renter.WalletBalance += unusedRent;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    UserId = renter.Id,
                    Amount = unusedRent,
                    Type = TransactionType.EscrowRelease,
                    Description = $"Refund for unused rent days on early return of rental {rental.Id}",
                    RelatedRentalId = rental.Id,
                    CreatedAt = DateTimeOffset.UtcNow
                });
                
                if (cancellationFee > 0)
                {
                    renter.WalletBalance -= cancellationFee;
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renter.Id,
                        Amount = -cancellationFee,
                        Type = TransactionType.Penalty,
                        Description = $"Early return cancellation fee for rental {rental.Id}",
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }
            }

            // If expert was NOT paid, refund the owner their expert fee share
            if (!rental.IsExpertPaid && ownerExpertFeeShare > 0)
            {
                owner.WalletBalance += ownerExpertFeeShare;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    UserId = owner.Id,
                    Amount = ownerExpertFeeShare,
                    Type = TransactionType.EscrowRelease,
                    Description = $"Expert Review Escrow refunded for rental {rental.Id}",
                    RelatedRentalId = rental.Id,
                    IsPending = false,
                    CreatedAt = DateTimeOffset.UtcNow
                });
            }

            if (grandTotalExtra > 0)
            {
                owner.PendingBalance += grandTotalExtra;
                _context.WalletTransactions.Add(new WalletTransaction {
                    UserId = owner.Id,
                    Amount = grandTotalExtra,
                    Type = TransactionType.PendingEarnings,
                    Description = $"Pending extra income (Late fee/Penalty) for '{rental.Item.TitleEn}' (Rental ID: {rental.Id})",
                    RelatedRentalId = rental.Id,
                    IsPending = true,
                    ReleaseDate = DateTimeOffset.UtcNow.AddDays(14),
                    CreatedAt = DateTimeOffset.UtcNow
                });
                
                // Deduct extra from renter's wallet (in a real system, you'd try to charge card if balance is insufficient)
                renter.WalletBalance -= lateFee;
            }
        }

        await _context.SaveChangesAsync(ct);

        // Notify renter
        var renterMsg = lateFee > 0
            ? $"Your rental for '{rental.Item.TitleEn}' is complete. Late fee: {lateFee:C}. Deposit: {rental.DepositStatus}."
            : $"Your rental for '{rental.Item.TitleEn}' is complete. Thank you!";
            
        var depositStatusAr = rental.DepositStatus == Domain.Enums.DepositStatus.Returned ? "تم الإرجاع" : "مخصوم";
        var renterMsgAr = lateFee > 0
            ? $"اكتمل إيجار '{rental.Item.TitleEn}'. رسوم التأخير: {lateFee:C}. التأمين: {depositStatusAr}."
            : $"اكتمل إيجار '{rental.Item.TitleEn}'. شكراً لك!";
            
        await _notifier.SendToUserAsync(rental.UserId, "Rental Completed", renterMsg, "rental", $"/rentals/{rental.Id}", ct, "اكتمل الإيجار", renterMsgAr);

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
                ct,
                titleAr: "منتج متاح",
                messageAr: $"المنتج '{itemTitle}' متاح للإيجار مرة أخرى!"
            );
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
    private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

    public CancelRentalCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<RentalActionResponse> Handle(CancelRentalCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        bool isAdmin = _httpContextAccessor.HttpContext?.User?.IsInRole("Admin") == true || 
                       _httpContextAccessor.HttpContext?.User?.IsInRole("SuperAdmin") == true;
        bool isRenter = rental.UserId == _currentUser.Id!.Value;
        bool isOwner = rental.Item.OwnerId == _currentUser.Id!.Value;
        bool isExpert = _httpContextAccessor.HttpContext?.User?.IsInRole("Expert") == true || (rental.Verifications.Any(v => v.ExpertId == _currentUser.Id!.Value));

        if (!isRenter && !isOwner && !isAdmin && !isExpert)
            return new RentalActionResponse(false, "Only the renter, owner, expert, or admin can cancel.", null);
            
        if (rental.Status == RentalStatus.Completed || rental.Status == RentalStatus.Cancelled || rental.Status == RentalStatus.Active || rental.Status == RentalStatus.Returned || rental.Status == RentalStatus.Overdue)
            return new RentalActionResponse(false, "Active or completed rentals cannot be cancelled. Please initiate a return instead.", null);

        var previousStatus = rental.Status;
        rental.Status = RentalStatus.Cancelled;
        rental.UpdatedAt = DateTime.UtcNow;

        if (rental.Item.Status == NewItemStatus.Rented)
        {
            rental.Item.Status = NewItemStatus.Available;
            rental.Item.UpdatedAt = DateTime.UtcNow;
        }

        // Release Escrow if Wallet payment
        var payment = await _context.Payments.FirstOrDefaultAsync(p => p.OrderId == rental.OrderId && p.Method == PaymentMethod.Wallet && p.Status == PaymentStatus.Success, ct);
        if (payment != null)
        {
            var renterUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.UserId, ct);
            if (renterUser != null)
            {
                // Determine if this is a "before receipt" cancellation (item was never received)
                bool beforeReceipt = previousStatus == RentalStatus.Pending 
                    || previousStatus == RentalStatus.Confirmed 
                    || previousStatus == RentalStatus.AwaitingPickup;

                // Read the fixed cancellation fee from system_settings
                var cancellationFeeSetting = await _context.SystemSettings
                    .FirstOrDefaultAsync(s => s.Key == "CancellationFee", ct);
                decimal fixedCancellationFee = 500m; // default
                if (cancellationFeeSetting != null && decimal.TryParse(cancellationFeeSetting.Value, out var parsedFee))
                    fixedCancellationFee = parsedFee;

                // Cancellation fee only applies when: renter cancels after owner confirmed (not from Pending)
                decimal cancellationFee = 0m;
                if (isRenter && previousStatus != RentalStatus.Pending && beforeReceipt)
                {
                    cancellationFee = fixedCancellationFee;
                }
                rental.CancellationFee = cancellationFee;

                // Fee split: 85% to owner, 15% to platform
                decimal ownerCompensation = cancellationFee > 0 ? Math.Round(cancellationFee * 0.85m, 2) : 0m;

                decimal renterExpertFeeShare = rental.RenterWantsExpertReview ? (rental.OwnerWantsExpertReview ? 50m : 100m) : 0m;
                decimal ownerExpertFeeShare = rental.OwnerWantsExpertReview ? (rental.RenterWantsExpertReview ? 50m : 100m) : 0m;

                decimal depositRefund = rental.DepositAmount;
                decimal rentalRefund = rental.RentalPrice - cancellationFee;
                decimal expertRefund = !rental.IsExpertPaid ? renterExpertFeeShare : 0m;

                decimal totalRenterRefund = depositRefund + rentalRefund + expertRefund;

                // --- Revert PendingBalance ---
                if (previousStatus != RentalStatus.Pending)
                {
                    // After confirmation: RentalPrice was moved to Owner's Pending, Renter still holds Deposit (+ expert fee) in Pending
                    var ownerUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.Item.OwnerId, ct);
                    if (ownerUser != null)
                    {
                        // 1. Revert the full rental price hold from owner's pending balance
                        ownerUser.PendingBalance -= rental.RentalPrice;

                        // 2. Give the owner their compensation as available balance
                        if (ownerCompensation > 0)
                        {
                            ownerUser.WalletBalance += ownerCompensation;
                            _context.WalletTransactions.Add(new WalletTransaction
                            {
                                UserId = ownerUser.Id,
                                Amount = ownerCompensation,
                                Type = TransactionType.RentalEarnings,
                                Description = $"Cancellation compensation (85%) for '{rental.Item.TitleEn}' (Rental ID: {rental.Id}).",
                                RelatedRentalId = rental.Id,
                                IsPending = false,
                                CreatedAt = DateTimeOffset.UtcNow
                            });
                        }

                        // 3. Refund owner their expert fee share if expert was not paid
                        if (!rental.IsExpertPaid && ownerExpertFeeShare > 0)
                        {
                            ownerUser.PendingBalance -= ownerExpertFeeShare;
                            ownerUser.WalletBalance += ownerExpertFeeShare;
                            _context.WalletTransactions.Add(new WalletTransaction
                            {
                                UserId = ownerUser.Id,
                                Amount = ownerExpertFeeShare,
                                Type = TransactionType.EscrowRelease,
                                Description = $"Refund of Expert Escrow for cancelled rental {rental.Id}",
                                RelatedRentalId = rental.Id,
                                IsPending = false,
                                CreatedAt = DateTimeOffset.UtcNow
                            });
                        }
                    }

                    // Renter's pending: Deposit + expert fee (RentalPrice was already moved to owner at confirmation)
                    decimal heldRenterPending = rental.DepositAmount + (!rental.IsExpertPaid ? renterExpertFeeShare : 0m);
                    renterUser.PendingBalance -= heldRenterPending;
                }
                else
                {
                    // From Pending: Renter's pending has everything (RentalPrice + Deposit + expert fee)
                    decimal heldRenterPending = rental.RentalPrice + rental.DepositAmount + (!rental.IsExpertPaid ? renterExpertFeeShare : 0m);
                    renterUser.PendingBalance -= heldRenterPending;
                }

                // --- Credit the renter ---
                renterUser.WalletBalance += totalRenterRefund;

                // Deposit refund transaction
                if (depositRefund > 0)
                {
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renterUser.Id,
                        Amount = depositRefund,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Deposit refund for cancelled rental {rental.Id}",
                        IsPending = false,
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }

                // Rental price refund transaction
                if (rental.RentalPrice > 0)
                {
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renterUser.Id,
                        Amount = rental.RentalPrice,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Rental refund for cancelled rental {rental.Id}",
                        IsPending = false,
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }

                // Expert fee refund transaction
                if (expertRefund > 0)
                {
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renterUser.Id,
                        Amount = expertRefund,
                        Type = TransactionType.EscrowRelease,
                        Description = $"Expert Review Escrow refunded for cancelled rental {rental.Id}",
                        IsPending = false,
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }

                // Cancellation fee transaction
                if (cancellationFee > 0)
                {
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        UserId = renterUser.Id,
                        Amount = -cancellationFee,
                        Type = TransactionType.Penalty,
                        Description = $"Cancellation fee",
                        IsPending = false,
                        RelatedRentalId = rental.Id,
                        CreatedAt = DateTimeOffset.UtcNow
                    });
                }

                await _notifier.SendToUserAsync(
                    renterUser.Id,
                    "Escrow Released",
                    $"The funds held for cancelled rental {rental.Id} have been returned to your wallet.",
                    "wallet",
                    "/wallet",
                    ct,
                    "تم تحرير المبلغ المحجوز",
                    $"تم إرجاع الأموال المحجوزة للإيجار الملغى رقم {rental.Id} إلى محفظتك."
                );
            }
        }

        await _context.SaveChangesAsync(ct);

        long userToNotify = isRenter ? rental.Item.OwnerId : rental.UserId;
        string actor = isRenter ? "the renter" : (isOwner ? "the owner" : "an admin");
        string actorAr = isRenter ? "المستأجر" : (isOwner ? "المالك" : "الإدارة");

        await _notifier.SendToUserAsync(
            userToNotify,
            "Rental Cancelled",
            $"The rental request for '{rental.Item.TitleEn}' was cancelled by {actor}.",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "إلغاء الإيجار",
            messageAr: $"تم إلغاء طلب الإيجار للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}' من قبل {actorAr}."
        );

        if (isAdmin)
        {
            // notify the other party as well
            long otherUser = isRenter ? rental.UserId : rental.Item.OwnerId;
            await _notifier.SendToUserAsync(
                otherUser,
                "Rental Cancelled",
                $"The rental request for '{rental.Item.TitleEn}' was cancelled by an admin.",
                "rental",
                $"/rentals/{rental.Id}",
                ct,
                titleAr: "إلغاء الإيجار",
                messageAr: $"تم إلغاء طلب الإيجار للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}' من قبل الإدارة."
            );
        }

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

        if (rental.Status == RentalStatus.Completed || rental.Status == RentalStatus.Cancelled || rental.Status == RentalStatus.Rejected)
            return false;

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

public record DeleteRentalPhotoCommand(Guid RentalId, string ImageUrl) : IRequest<bool>;

public class DeleteRentalPhotoCommandHandler : IRequestHandler<DeleteRentalPhotoCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public DeleteRentalPhotoCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(DeleteRentalPhotoCommand request, CancellationToken ct)
    {
        var rentalImage = await _context.RentalImages
            .Include(ri => ri.Image)
            .Include(ri => ri.Rental)
            .ThenInclude(r => r.Item)
            .FirstOrDefaultAsync(ri => ri.RentalId == request.RentalId && request.ImageUrl.EndsWith(ri.Image.StoragePath), ct);

        if (rentalImage == null) return false;

        var rental = rentalImage.Rental;
        if (rentalImage.Image.CreatedBy.HasValue && rentalImage.Image.CreatedBy.Value != _currentUser.Id!.Value)
            return false;

        _context.RentalImages.Remove(rentalImage);
        await _context.SaveChangesAsync(ct);
        return true;
    }
}

public record RequestExpertReviewCommand(Guid RentalId) : IRequest<RentalActionResponse>;

public class RequestExpertReviewCommandHandler : IRequestHandler<RequestExpertReviewCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly Microsoft.AspNetCore.Identity.UserManager<ApplicationUser> _userManager;
    private readonly INotificationSender _notifier;

    public RequestExpertReviewCommandHandler(
        IApplicationDbContext context, 
        IUser currentUser,
        Microsoft.AspNetCore.Identity.UserManager<ApplicationUser> userManager,
        INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _userManager = userManager;
        _notifier = notifier;
    }

    public async Task<RentalActionResponse> Handle(RequestExpertReviewCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications).ThenInclude(v => v.Expert)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);

        if (!_currentUser.Id.HasValue)
            return new RentalActionResponse(false, "User session not found.", null);

        if (rental.Item.OwnerId != _currentUser.Id.Value)
            return new RentalActionResponse(false, "Only the owner can request an expert review from this endpoint.", null);

        if (rental.OwnerWantsExpertReview)
            return new RentalActionResponse(false, "Expert review already requested by owner.", null);

        var owner = await _context.Users.FindAsync(rental.Item.OwnerId);
        if (owner == null) return new RentalActionResponse(false, "Owner not found.", null);

        decimal ownerShare = rental.RenterWantsExpertReview ? 50m : 100m;
        
        System.IO.File.AppendAllText("/tmp/renty_debug.txt", $"Owner: {owner.Id}, Balance: {owner.WalletBalance}, Share: {ownerShare}\n");
        if (owner.WalletBalance < ownerShare)
            return new RentalActionResponse(false, $"Insufficient balance. You need {ownerShare} EGP in your wallet to request an expert review.", null);

        // Deduct from Owner
        owner.WalletBalance -= ownerShare;
        owner.PendingBalance += ownerShare;

        _context.WalletTransactions.Add(new WalletTransaction
        {
            UserId = owner.Id,
            Amount = -ownerShare,
            Type = TransactionType.EscrowHold,
            Description = $"Expert Escrow hold (Owner Share) for rental order {rental.OrderId}",
            IsPending = true,
            CreatedAt = DateTimeOffset.UtcNow
        });

        // Refund Renter if they already paid 100
        if (rental.RenterWantsExpertReview)
        {
            var renter = await _context.Users.FindAsync(rental.UserId);
            if (renter != null)
            {
                renter.PendingBalance -= 50m;
                renter.WalletBalance += 50m;

                _context.WalletTransactions.Add(new WalletTransaction
                {
                    UserId = renter.Id,
                    Amount = 50m,
                    Type = TransactionType.EscrowRelease,
                    Description = $"Expert Escrow partial refund (Owner requested expert too) for rental order {rental.OrderId}",
                    IsPending = false,
                    CreatedAt = DateTimeOffset.UtcNow
                });
            }
        }
        else
        {
            // If renter didn't request it, the total ExpertReviewFee on the rental becomes 100.
            rental.ExpertReviewFee = 100;
        }

        rental.OwnerWantsExpertReview = true;
        rental.UpdatedAt = DateTime.UtcNow;

        if (rental.Status == RentalStatus.Pending || rental.Status == RentalStatus.Confirmed)
        {
            if (!rental.Verifications.Any(v => v.CheckType == VerificationCheck.BeforeRent))
            {
                var verification = new ItemVerification
                {
                    ItemId = rental.ItemId,
                    RentalId = rental.Id,
                    CheckType = VerificationCheck.BeforeRent,
                    Status = VerificationStatus.Pending,
                    VerificationCode = new Random().Next(100000, 999999).ToString(),
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.ItemVerifications.Add(verification);
            }
        }

        try 
        {
            await _context.SaveChangesAsync(ct);
            
            // Notify experts
            var experts = await _userManager.GetUsersInRoleAsync("Expert");
            if (experts.Any())
            {
                var expertIds = experts.Select(e => e.Id).ToList();
                await _notifier.SendToUsersAsync(
                    expertIds,
                    "New Expert Task",
                    $"A new item verification has been requested for '{rental.Item.TitleEn}'.",
                    "verification",
                    "/expert/assigned",
                    ct,
                    titleAr: "مهمة خبير جديدة",
                    messageAr: $"تم طلب تحقق جديد للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'."
                );
            }
        }
        catch (DbUpdateConcurrencyException)
        {
            return new RentalActionResponse(false, "The rental was updated by another process. Please refresh and try again.", null);
        }
        return new RentalActionResponse(true, null, rental.Status.ToString());
    }
}

public record CancelExpertReviewCommand(Guid RentalId) : IRequest<RentalActionResponse>;

public class CancelExpertReviewCommandHandler : IRequestHandler<CancelExpertReviewCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CancelExpertReviewCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RentalActionResponse> Handle(CancelExpertReviewCommand request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications).ThenInclude(v => v.Expert)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new RentalActionResponse(false, "Rental not found.", null);
        if (!_currentUser.Id.HasValue) return new RentalActionResponse(false, "Unauthorized.", null);

        bool isOwner = rental.Item.OwnerId == _currentUser.Id.Value;
        bool isRenter = rental.UserId == _currentUser.Id.Value;

        if (!isOwner && !isRenter)
            return new RentalActionResponse(false, "Unauthorized.", null);

        if (isOwner && !rental.OwnerWantsExpertReview)
            return new RentalActionResponse(false, "You haven't requested an expert review.", null);
        if (isRenter && !rental.RenterWantsExpertReview)
            return new RentalActionResponse(false, "You haven't requested an expert review.", null);

        if (rental.AssignedExpertId.HasValue)
            return new RentalActionResponse(false, "Cannot cancel after an expert has been assigned.", null);

        if (isOwner) rental.OwnerWantsExpertReview = false;
        else rental.RenterWantsExpertReview = false;

        rental.UpdatedAt = DateTime.UtcNow;

        // If no one wants it anymore, remove pending verifications
        if (!rental.OwnerWantsExpertReview && !rental.RenterWantsExpertReview)
        {
            var pending = rental.Verifications.Where(v => v.Status == VerificationStatus.Pending).ToList();
            if (pending.Any())
            {
                _context.ItemVerifications.RemoveRange(pending);
            }
        }

        await _context.SaveChangesAsync(ct);
        return new RentalActionResponse(true, "Expert review request cancelled.", rental.Status.ToString());
    }
}

public record UpdatePossessionCommand(
    Guid RentalId,
    string Action,
    string DeliveryMethod
) : IRequest<RentalActionResponse>;

public class UpdatePossessionCommandHandler : IRequestHandler<UpdatePossessionCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public UpdatePossessionCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<RentalActionResponse> Handle(UpdatePossessionCommand request, CancellationToken ct)
    {
        if (!_currentUser.Id.HasValue)
            return new RentalActionResponse(false, "Unauthorized.", null);

        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Verifications)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null)
            return new RentalActionResponse(false, "Rental not found.", null);

        var userId = _currentUser.Id.Value;
        bool isOwner = rental.Item.OwnerId == userId;
        bool isRenter = rental.UserId == userId;

        if (!Enum.TryParse<DeliveryMethod>(request.DeliveryMethod, true, out var method))
            return new RentalActionResponse(false, "Invalid delivery method.", null);

        if (request.Action.ToLower() == "send_to_expert")
        {
            if (!isOwner)
                return new RentalActionResponse(false, "Only the owner can send the item to the expert.", null);

            rental.DeliveryMethod = method;
            if (method == DeliveryMethod.DeliveryService)
            {
                rental.CurrentPossession = ItemPossession.InTransit;
            }
            else
            {
                rental.CurrentPossession = ItemPossession.Expert;
            }
            rental.UpdatedAt = DateTime.UtcNow;

            await _notifier.SendToUserAsync(
                rental.UserId,
                "Item Sent to Expert",
                $"The owner has sent the item for expert review.",
                "rental",
                $"/rentals/{rental.Id}",
                ct,
                titleAr: "تم إرسال المنتج للخبير",
                messageAr: "قام المالك بإرسال المنتج لمراجعة الخبير."
            );
        }
        else if (request.Action.ToLower() == "initiate_return")
        {
            if (!isRenter)
                return new RentalActionResponse(false, "Only the renter can initiate the return.", null);

            rental.DeliveryMethod = method;
            var needsPostCheck = rental.RenterWantsExpertReview || rental.OwnerWantsExpertReview;

            if (needsPostCheck)
            {
                if (!rental.Verifications.Any(v => v.CheckType == VerificationCheck.AfterReturn))
                {
                    rental.Verifications.Add(new ItemVerification
                    {
                        ItemId = rental.ItemId,
                        RentalId = rental.Id,
                        CheckType = VerificationCheck.AfterReturn,
                        Status = VerificationStatus.Pending,
                        VerificationCode = new Random().Next(100000, 999999).ToString(),
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    });
                }
            }

            if (method == DeliveryMethod.DeliveryService)
            {
                rental.CurrentPossession = ItemPossession.InTransit;
            }
            else
            {
                rental.CurrentPossession = needsPostCheck ? ItemPossession.Expert : ItemPossession.Owner;
            }
            rental.UpdatedAt = DateTime.UtcNow;

            await _notifier.SendToUserAsync(
                rental.Item.OwnerId,
                "Return Initiated",
                $"The renter has initiated the return of '{rental.Item.TitleEn}'.",
                "rental",
                $"/rentals/{rental.Id}",
                ct,
                titleAr: "بدء الإرجاع",
                messageAr: $"قام المستأجر ببدء عملية إرجاع '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'."
            );

            if (needsPostCheck && rental.AssignedExpertId.HasValue)
            {
                await _notifier.SendToUserAsync(
                    rental.AssignedExpertId.Value,
                    "Expert Review Required",
                    $"The rental for '{rental.Item.TitleEn}' has finished and is ready for your After-Return evaluation.",
                    "verification",
                    "/expert/assigned",
                    ct,
                    titleAr: "مطلوب مراجعة الخبير",
                    messageAr: $"لقد انتهى إيجار '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}' وهو جاهز لتقييمك بعد الإرجاع."
                );
            }
        }
        else if (request.Action.ToLower() == "confirm_receipt")
        {
            if (rental.CurrentPossession != ItemPossession.InTransit)
                return new RentalActionResponse(false, "Item is not currently in transit.", null);

            var hasPendingVerification = rental.Verifications.Any(v => v.Status == VerificationStatus.Pending);
            if (hasPendingVerification)
            {
                rental.CurrentPossession = ItemPossession.Expert;
            }
            else
            {
                rental.CurrentPossession = isOwner ? ItemPossession.Owner : ItemPossession.Renter;
            }
            rental.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            return new RentalActionResponse(false, "Invalid action.", null);
        }

        await _context.SaveChangesAsync(ct);
        return new RentalActionResponse(true, "Possession updated successfully.", rental.Status.ToString());
    }
}
