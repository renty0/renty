using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Rentals;

// ── RENTAL EXTENSION DTOs ─────────────────────────────────────────────────────

public record RentalExtensionDto(
    Guid Id,
    Guid RentalId,
    DateTime NewEndDate,
    int ExtraDays,
    decimal ExtraCost,
    string Status,
    DateTime CreatedAt
);

// ── REQUEST EXTENSION ─────────────────────────────────────────────────────────

public record RequestExtensionCommand(
    Guid RentalId,
    int ExtraDays
) : IRequest<RequestExtensionResponse>;

public record RequestExtensionResponse(bool Success, string? Error, Guid? ExtensionId, DateTime? NewEndDate, decimal? ExtraCost);

public class RequestExtensionCommandValidator : AbstractValidator<RequestExtensionCommand>
{
    public RequestExtensionCommandValidator()
    {
        RuleFor(x => x.RentalId).NotEmpty();
        RuleFor(x => x.ExtraDays).GreaterThan(0).WithMessage("Extra days must be at least 1.");
    }
}

public class RequestExtensionCommandHandler : IRequestHandler<RequestExtensionCommand, RequestExtensionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public RequestExtensionCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<RequestExtensionResponse> Handle(RequestExtensionCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new RequestExtensionResponse(false, "Unauthorized.", null, null, null);

        var rental = await _context.Rentals
            .Include(r => r.Item).ThenInclude(i => i.Pricing)
            .Include(r => r.Extensions)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null)
            return new RequestExtensionResponse(false, "Rental not found.", null, null, null);

        if (rental.UserId != _currentUser.Id.Value)
            return new RequestExtensionResponse(false, "Only the renter can request an extension.", null, null, null);

        if (rental.Status != RentalStatus.Active && rental.Status != RentalStatus.Extended)
            return new RequestExtensionResponse(false, "Extensions can only be requested for active rentals.", null, null, null);

        // Check for existing pending extension
        if (rental.Extensions.Any(e => e.Status == ExtensionStatus.Pending))
            return new RequestExtensionResponse(false, "There is already a pending extension request.", null, null, null);

        // Check for overlapping rentals on the new end date
        var newEndDate = rental.EndDate.AddDays(request.ExtraDays);
        var overlapping = await _context.Rentals.AnyAsync(r =>
            r.ItemId == rental.ItemId &&
            r.Id != rental.Id &&
            r.Status != RentalStatus.Cancelled && r.Status != RentalStatus.Rejected &&
            r.StartDate < newEndDate && r.EndDate > rental.EndDate, ct);

        if (overlapping)
            return new RequestExtensionResponse(false, "Cannot extend — item is booked for overlapping dates.", null, null, null);

        // Calculate extra cost based on daily pricing
        var dailyPricing = rental.Item.Pricing.FirstOrDefault(p => p.PricingType == "daily");
        var dailyRate = dailyPricing?.Price ?? (rental.RentalPrice / Math.Max(1, (decimal)(rental.EndDate - rental.StartDate).TotalDays));
        var extraCost = Math.Round(dailyRate * request.ExtraDays, 2);

        var extension = new RentalExtension
        {
            RentalId = rental.Id,
            RequestedBy = _currentUser.Id.Value,
            NewEndDate = newEndDate,
            ExtraDays = request.ExtraDays,
            ExtraCost = extraCost,
            Status = ExtensionStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.RentalExtensions.Add(extension);
        await _context.SaveChangesAsync(ct);

        // Notify owner
        await _notifier.SendToUserAsync(
            rental.Item.OwnerId,
            "Extension Request",
            $"The renter has requested a {request.ExtraDays}-day extension for '{rental.Item.TitleEn}'.",
            "rental",
            $"/rentals/{rental.Id}",
            ct,
            titleAr: "طلب تمديد",
            messageAr: $"طلب المستأجر تمديد {request.ExtraDays} يوم للمنتج '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'.");

        return new RequestExtensionResponse(true, null, extension.Id, newEndDate, extraCost);
    }
}

// ── RESPOND TO EXTENSION ──────────────────────────────────────────────────────

public record RespondToExtensionCommand(
    Guid RentalId,
    Guid ExtensionId,
    bool Approve
) : IRequest<RespondToExtensionResponse>;

public record RespondToExtensionResponse(bool Success, string? Error, string? Status, DateTime? NewEndDate);

public class RespondToExtensionCommandHandler : IRequestHandler<RespondToExtensionCommand, RespondToExtensionResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public RespondToExtensionCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<RespondToExtensionResponse> Handle(RespondToExtensionCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new RespondToExtensionResponse(false, "Unauthorized.", null, null);

        var rental = await _context.Rentals
            .Include(r => r.Item)
            .Include(r => r.Extensions)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null)
            return new RespondToExtensionResponse(false, "Rental not found.", null, null);

        if (rental.Item.OwnerId != _currentUser.Id.Value)
            return new RespondToExtensionResponse(false, "Only the owner can respond to extension requests.", null, null);

        var extension = rental.Extensions.FirstOrDefault(e => e.Id == request.ExtensionId);
        if (extension == null)
            return new RespondToExtensionResponse(false, "Extension request not found.", null, null);

        if (extension.Status != ExtensionStatus.Pending)
            return new RespondToExtensionResponse(false, "Extension has already been responded to.", null, null);

        if (request.Approve)
        {
            extension.Status = ExtensionStatus.Approved;
            rental.EndDate = extension.NewEndDate;
            rental.RentalPrice += extension.ExtraCost;
            rental.Status = RentalStatus.Extended;
            rental.UpdatedAt = DateTime.UtcNow;

            await _notifier.SendToUserAsync(
                rental.UserId,
                "Extension Approved",
                $"Your extension request for '{rental.Item.TitleEn}' has been approved. New end date: {extension.NewEndDate:yyyy-MM-dd}.",
                "rental",
                $"/rentals/{rental.Id}",
                ct,
                titleAr: "تم قبول التمديد",
                messageAr: $"تم قبول طلب تمديد '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'. تاريخ الانتهاء الجديد: {extension.NewEndDate:yyyy-MM-dd}.");
        }
        else
        {
            extension.Status = ExtensionStatus.Rejected;
            
            await _notifier.SendToUserAsync(
                rental.UserId,
                "Extension Rejected",
                $"Your extension request for '{rental.Item.TitleEn}' has been rejected by the owner.",
                "rental",
                $"/rentals/{rental.Id}",
                ct,
                titleAr: "تم رفض التمديد",
                messageAr: $"تم رفض طلب تمديد '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}' من قبل المالك.");
        }

        extension.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);

        return new RespondToExtensionResponse(true, null, extension.Status.ToString(), extension.Status == ExtensionStatus.Approved ? extension.NewEndDate : null);
    }
}
