using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Features.Rentals;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Verifications;

// ── DTOs ─────────────────────────────────────────────────────────────────────

// DTOs are now in Application.Common.Models

public record AssignedVerificationDto(
    Guid VerificationId, Guid ItemId,
    string ItemTitleAr, string ItemTitleEn, string? ItemImage,
    DateTime? RentalStartDate, DateTime? RentalEndDate,
    string CheckType, DateTime CreatedAt
);

// ── CREATE VERIFICATION ───────────────────────────────────────────────────────

public record CreateVerificationCommand(
    Guid ItemId,
    Guid? RentalId,
    string CheckType,
    string Status,
    string? Notes = null,
    decimal? DeductionAmount = null,
    decimal? NewDepositAmount = null,
    string? VerificationCode = null
) : IRequest<CreateVerificationResponse>;

public record CreateVerificationResponse(bool Success, string? Error, Guid? VerificationId, string? Status);

public class CreateVerificationCommandValidator : AbstractValidator<CreateVerificationCommand>
{
    public CreateVerificationCommandValidator()
    {
        RuleFor(x => x.ItemId).NotEmpty();
        RuleFor(x => x.CheckType)
            .Must(t => t == "before_rent" || t == "after_return")
            .WithMessage("checkType must be before_rent or after_return.");
        RuleFor(x => x.Status)
            .Must(s => s == "pending" || s == "approved" || s == "rejected")
            .WithMessage("status must be pending, approved, or rejected.");
    }
}

public class CreateVerificationCommandHandler : IRequestHandler<CreateVerificationCommand, CreateVerificationResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public CreateVerificationCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<CreateVerificationResponse> Handle(CreateVerificationCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateVerificationResponse(false, "Unauthorized.", null, null);

        var item = await _context.Items.FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);
        if (item == null) return new CreateVerificationResponse(false, "Item not found.", null, null);

        // Self-verification check (DB trigger also enforces this)
        if (item.OwnerId == _currentUser.Id.Value)
            return new CreateVerificationResponse(false, "An expert cannot verify their own item.", null, null);

        Enum.TryParse<VerificationCheck>(request.CheckType.Replace("_", ""), true, out var checkType);
        Enum.TryParse<VerificationStatus>(request.Status, true, out var status);

        var cleanNotes = request.Notes;

        var verification = await _context.ItemVerifications
            .FirstOrDefaultAsync(v => v.ItemId == request.ItemId && v.ExpertId == _currentUser.Id.Value && v.Status == VerificationStatus.Pending, ct);

        if (verification != null)
        {

            verification.Status = status;
            verification.Notes = cleanNotes;
            verification.CheckType = checkType;
            if (request.RentalId.HasValue) verification.RentalId = request.RentalId;
            verification.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            verification = new ItemVerification
            {
                ItemId = request.ItemId,
                ExpertId = _currentUser.Id.Value,
                RentalId = request.RentalId,
                CheckType = checkType,
                Status = status,
                Notes = cleanNotes,
                VerificationCode = new Random().Next(100000, 999999).ToString(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.ItemVerifications.Add(verification);
        }

        var rentalIdToUse = request.RentalId ?? verification?.RentalId;

        // Update rental state if applicable
        if (rentalIdToUse.HasValue)
        {
            var rental = await _context.Rentals.FirstOrDefaultAsync(r => r.Id == rentalIdToUse.Value, ct);
            if (rental != null)
            {
                if (checkType == VerificationCheck.BeforeRent)
                {
                    if (status == VerificationStatus.Approved)
                    {
                        // The item is now safely with the Expert and approved.
                        // The renter will now choose how to receive it.
                        rental.CurrentPossession = ItemPossession.Expert;

                        // Auto-assign AfterReturn verification to the same expert
                        var existingAfterReturn = await _context.ItemVerifications
                            .AnyAsync(v => v.RentalId == rental.Id && v.CheckType == VerificationCheck.AfterReturn, ct);
                        
                        if (!existingAfterReturn)
                        {
                            var afterReturnVerification = new ItemVerification
                            {
                                ItemId = request.ItemId,
                                ExpertId = _currentUser.Id.Value,
                                RentalId = rental.Id,
                                CheckType = VerificationCheck.AfterReturn,
                                Status = VerificationStatus.Pending,
                                VerificationCode = new Random().Next(100000, 999999).ToString(),
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow
                            };
                            _context.ItemVerifications.Add(afterReturnVerification);
                        }

                        if (request.NewDepositAmount.HasValue)
                        {
                            rental.DepositAmount = request.NewDepositAmount.Value;
                        }
                    }
                    else if (status == VerificationStatus.Rejected)
                    {
                        rental.Status = Domain.Enums.RentalStatus.Rejected;
                        item.Status = Domain.Enums.NewItemStatus.Available;
                        rental.CurrentPossession = rental.DeliveryMethod == Domain.Enums.DeliveryMethod.DeliveryService 
                            ? ItemPossession.InTransit 
                            : ItemPossession.Owner;
                    }

                    // Pay the expert if they haven't been paid for this rental yet
                    if ((status == VerificationStatus.Approved || status == VerificationStatus.Rejected) && 
                        !rental.IsExpertPaid && rental.ExpertReviewFee > 0)
                    {
                        var expert = await _context.Users.FirstOrDefaultAsync(u => u.Id == verification.ExpertId, ct);
                        if (expert != null)
                        {
                            expert.WalletBalance += rental.ExpertReviewFee;
                            _context.WalletTransactions.Add(new WalletTransaction
                            {
                                UserId = expert.Id,
                                Amount = rental.ExpertReviewFee,
                                Type = TransactionType.RentalEarnings,
                                Description = $"Expert Review Fee earned for rental {rental.Id}",
                                RelatedRentalId = rental.Id,
                                IsPending = false,
                                CreatedAt = DateTimeOffset.UtcNow
                            });

                            // Deduct the held escrows from Renter and Owner
                            decimal renterShare = rental.RenterWantsExpertReview ? (rental.OwnerWantsExpertReview ? 50m : 100m) : 0m;
                            decimal ownerShare = rental.OwnerWantsExpertReview ? (rental.RenterWantsExpertReview ? 50m : 100m) : 0m;

                            if (renterShare > 0)
                            {
                                var renter = await _context.Users.FirstOrDefaultAsync(u => u.Id == rental.UserId, ct);
                                if (renter != null) renter.PendingBalance -= renterShare;
                            }
                            if (ownerShare > 0)
                            {
                                var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == item.OwnerId, ct);
                                if (owner != null) owner.PendingBalance -= ownerShare;
                            }

                            rental.IsExpertPaid = true;
                        }
                    }
                }
                else if (checkType == VerificationCheck.AfterReturn)
                {
                    if (status == VerificationStatus.Approved)
                    {
                        rental.Status = Domain.Enums.RentalStatus.Returned;
                        rental.ActualReturnDate = DateTime.UtcNow;
                        rental.DepositStatus = Domain.Enums.DepositStatus.Returned;
                        
                        // Item stays with the expert until the owner selects a delivery method
                        rental.CurrentPossession = ItemPossession.Expert;
                        item.Status = Domain.Enums.NewItemStatus.Available;
                    }
                    else if (status == VerificationStatus.Rejected)
                    {
                        rental.DepositStatus = Domain.Enums.DepositStatus.Forfeited;
                        if (request.DeductionAmount.HasValue)
                        {
                            rental.RejectionFeeAmount = request.DeductionAmount.Value;
                        }
                        
                        rental.CurrentPossession = rental.DeliveryMethod == Domain.Enums.DeliveryMethod.DeliveryService 
                            ? ItemPossession.InTransit 
                            : ItemPossession.Owner;
                    }
                }

                // Notify users
                var notifyIds = new List<long> { rental.UserId, item.OwnerId }.Distinct().ToList();
                var statusAr = status == VerificationStatus.Approved ? "مقبول" : "مرفوض";
                await _notifier.SendToUsersAsync(
                    notifyIds,
                    "Expert Evaluation Complete",
                    $"The expert has completed the evaluation for '{item.TitleEn}'. Status: {status}.",
                    "rental",
                    $"/rentals/{rental.Id}",
                    ct,
                    titleAr: "اكتمل تقييم الخبير",
                    messageAr: $"أكمل الخبير تقييم '{(!string.IsNullOrWhiteSpace(item.TitleAr) ? item.TitleAr : item.TitleEn)}'. الحالة: {statusAr}."
                );
            }
        }

        await _context.SaveChangesAsync(ct);
        return new CreateVerificationResponse(true, null, verification.Id, verification.Status.ToString());
    }
}

// ── GET VERIFICATIONS ─────────────────────────────────────────────────────────

public record GetVerificationsQuery(Guid ItemId) : IRequest<GetVerificationsResponse>;
public record GetVerificationsResponse(bool Success, string? Error, ItemVerificationDetailsDto? ItemDetails, List<VerificationDto>? Verifications);

public class GetVerificationsQueryHandler : IRequestHandler<GetVerificationsQuery, GetVerificationsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetVerificationsQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetVerificationsResponse> Handle(GetVerificationsQuery request, CancellationToken ct)
    {
        var item = await _context.Items
            .Include(i => i.Owner)
            .Include(i => i.Images).ThenInclude(img => img.Image)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null) return new GetVerificationsResponse(false, "Item not found.", null, null);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : "";

        // Find the most recent rental for this item to provide context
        var rental = await _context.Rentals
            .Include(r => r.User)
            .Where(r => r.ItemId == request.ItemId)
            .OrderByDescending(r => r.CreatedAt)
            .FirstOrDefaultAsync(ct);

        var storagePath = item.Images.Where(i => i.IsPrimary).Select(i => i.Image.StoragePath).FirstOrDefault()
                ?? item.Images.Select(i => i.Image.StoragePath).FirstOrDefault();
        var imageUrl = !string.IsNullOrEmpty(storagePath)
            ? (storagePath.StartsWith("http") ? storagePath : $"{baseUrl.TrimEnd('/')}/{storagePath.Replace("\\\\", "/").TrimStart('/')}")
            : null;

        var ownerDto = new PersonInfoDto(item.Owner.FullName, item.Owner.PhoneNumber, item.Owner.ProfilePictureUrl);
        
        RentalInfoDto? rentalDto = null;
        if (rental != null)
        {
            var renterDto = new PersonInfoDto(rental.User.FullName, rental.User.PhoneNumber, rental.User.ProfilePictureUrl);
            bool hasReturnTransfers = await _context.RentalTransfers.AnyAsync(t => t.RentalId == rental.Id && t.Phase == TransferPhase.Return, ct);
            
            string? pendingTransferType = null;
            var activeTransfer = await _context.RentalTransfers
                .Where(t => t.RentalId == rental.Id && t.Sequence == rental.CurrentTransferSequence && (t.Status == TransferStatus.Pending || t.Status == TransferStatus.WaitingForCode))
                .FirstOrDefaultAsync(ct);
            if (activeTransfer != null) 
            {
                if (activeTransfer.FromActorType == TransferActorType.Owner && activeTransfer.ToActorType == TransferActorType.Expert)
                    pendingTransferType = "ReceiveFromOwner";
                else if (activeTransfer.FromActorType == TransferActorType.Expert && activeTransfer.ToActorType == TransferActorType.Renter)
                    pendingTransferType = "DeliveryToRenter";
                else if (activeTransfer.FromActorType == TransferActorType.Renter && activeTransfer.ToActorType == TransferActorType.Expert)
                    pendingTransferType = "ReceiveFromRenter";
                else if (activeTransfer.FromActorType == TransferActorType.Expert && activeTransfer.ToActorType == TransferActorType.Owner)
                    pendingTransferType = "DeliveryToOwner";
            }

            rentalDto = new RentalInfoDto(rental.Id, rental.StartDate, rental.EndDate, rental.RentalPrice, rental.DepositAmount, rental.Status.ToString(), renterDto, rental.CurrentPossession.ToString(), hasReturnTransfers, pendingTransferType);
        }

        var itemDetails = new ItemVerificationDetailsDto(
            item.Id, item.TitleAr, item.TitleEn, imageUrl, item.Condition, item.City, ownerDto, rentalDto
        );

        var verifications = await _context.ItemVerifications
            .Include(v => v.Expert)
            .Where(v => v.ItemId == request.ItemId)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new VerificationDto(
                v.Id, v.CheckType.ToString(), v.Status.ToString(), v.Notes,
                v.Expert != null ? v.Expert.FirstName : null,
                v.CreatedAt, v.VerificationCode
            ))
            .ToListAsync(ct);

        return new GetVerificationsResponse(true, null, itemDetails, verifications);
    }
}

// ── GET EXPERT ASSIGNED ───────────────────────────────────────────────────────

public record GetExpertAssignedQuery : IRequest<GetExpertAssignedResponse>;
public record GetExpertAssignedResponse(List<AssignedVerificationDto> Assignments);

public class GetExpertAssignedQueryHandler : IRequestHandler<GetExpertAssignedQuery, GetExpertAssignedResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetExpertAssignedQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetExpertAssignedResponse> Handle(GetExpertAssignedQuery request, CancellationToken ct)
    {
        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : "";

        var rawAssignments = await _context.ItemVerifications
            .Include(v => v.Item).ThenInclude(i => i.Images).ThenInclude(ii => ii.Image)
            .Include(v => v.Rental)
            .Where(v => v.ExpertId == _currentUser.Id!.Value && v.Status == VerificationStatus.Pending)
            .Where(v => v.RentalId == null || (v.Rental!.Status != Domain.Enums.RentalStatus.Cancelled && v.Rental.Status != Domain.Enums.RentalStatus.Rejected))
            .OrderByDescending(v => v.CreatedAt)
            .ToListAsync(ct);

        var assignments = rawAssignments.Select(v =>
        {
            var storagePath = v.Item.Images.Where(i => i.IsPrimary).Select(i => i.Image.StoragePath).FirstOrDefault()
                ?? v.Item.Images.Select(i => i.Image.StoragePath).FirstOrDefault();
            var imageUrl = !string.IsNullOrEmpty(storagePath)
                ? (storagePath.StartsWith("http") ? storagePath : $"{baseUrl.TrimEnd('/')}/{storagePath.Replace("\\\\", "/").TrimStart('/')}")
                : null;
            return new AssignedVerificationDto(
                v.Id,
                v.ItemId,
                v.Item.TitleAr,
                v.Item.TitleEn,
                imageUrl,
                v.Rental?.StartDate,
                v.Rental?.EndDate,
                v.CheckType.ToString(),
                v.CreatedAt
            );
        }).ToList();

        return new GetExpertAssignedResponse(assignments);
    }
}

// ── GET UNASSIGNED VERIFICATIONS ──────────────────────────────────────────────

public record GetUnassignedVerificationsQuery : IRequest<GetExpertAssignedResponse>;

public class GetUnassignedVerificationsQueryHandler : IRequestHandler<GetUnassignedVerificationsQuery, GetExpertAssignedResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetUnassignedVerificationsQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetExpertAssignedResponse> Handle(GetUnassignedVerificationsQuery request, CancellationToken ct)
    {
        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : "";

        var rawAssignments = await _context.ItemVerifications
            .Include(v => v.Item).ThenInclude(i => i.Images).ThenInclude(ii => ii.Image)
            .Include(v => v.Rental)
            .Where(v => v.ExpertId == null && v.Status == VerificationStatus.Pending)
            .Where(v => v.RentalId == null || (v.Rental!.Status != Domain.Enums.RentalStatus.Cancelled && v.Rental.Status != Domain.Enums.RentalStatus.Rejected))
            .OrderByDescending(v => v.CreatedAt)
            .ToListAsync(ct);

        var assignments = rawAssignments.Select(v =>
        {
            var storagePath = v.Item.Images.Where(i => i.IsPrimary).Select(i => i.Image.StoragePath).FirstOrDefault()
                ?? v.Item.Images.Select(i => i.Image.StoragePath).FirstOrDefault();
            var imageUrl = !string.IsNullOrEmpty(storagePath)
                ? (storagePath.StartsWith("http") ? storagePath : $"{baseUrl.TrimEnd('/')}/{storagePath.Replace("\\\\", "/").TrimStart('/')}")
                : null;
            return new AssignedVerificationDto(
                v.Id,
                v.ItemId,
                v.Item.TitleAr,
                v.Item.TitleEn,
                imageUrl,
                v.Rental?.StartDate,
                v.Rental?.EndDate,
                v.CheckType.ToString(),
                v.CreatedAt
            );
        }).ToList();

        return new GetExpertAssignedResponse(assignments);
    }
}

// ── CLAIM VERIFICATION ───────────────────────────────────────────────────────

public record ClaimVerificationCommand(Guid VerificationId) : IRequest<RentalActionResponse>;

public class ClaimVerificationCommandHandler : IRequestHandler<ClaimVerificationCommand, RentalActionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public ClaimVerificationCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RentalActionResponse> Handle(ClaimVerificationCommand request, CancellationToken ct)
    {
        if (!_currentUser.Id.HasValue) return new RentalActionResponse(false, "Unauthorized.", null);

        var verification = await _context.ItemVerifications
            .Include(v => v.Item)
            .FirstOrDefaultAsync(v => v.Id == request.VerificationId, ct);

        if (verification == null) return new RentalActionResponse(false, "Verification not found.", null);
        
        if (verification.ExpertId.HasValue) 
            return new RentalActionResponse(false, "Verification already assigned to another expert.", null);

        if (verification.Item.OwnerId == _currentUser.Id.Value)
            return new RentalActionResponse(false, "You cannot verify your own item.", null);

        verification.ExpertId = _currentUser.Id.Value;
        verification.UpdatedAt = DateTime.UtcNow;

        if (verification.RentalId.HasValue)
        {
            var rental = await _context.Rentals
                .Include(r => r.Transfers)
                .FirstOrDefaultAsync(r => r.Id == verification.RentalId.Value, ct);

            if (rental != null)
            {
                rental.AssignedExpertId = _currentUser.Id.Value;
                
                // Update any existing transfers that should involve this expert
                foreach (var transfer in rental.Transfers)
                {
                    if (transfer.FromActorType == Domain.Enums.TransferActorType.Expert)
                        transfer.FromActorId = _currentUser.Id.Value;
                    
                    if (transfer.ToActorType == Domain.Enums.TransferActorType.Expert)
                        transfer.ToActorId = _currentUser.Id.Value;
                }
            }
        }

        await _context.SaveChangesAsync(ct);
        return new RentalActionResponse(true, "Verification claimed successfully.", null);
    }
}
