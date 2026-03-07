using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Verifications;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record VerificationDto(
    Guid Id, string CheckType, string Status, string? Notes,
    string? ExpertFirstName, DateTime CreatedAt
);

public record AssignedVerificationDto(
    Guid VerificationId,
    string ItemTitleAr, string ItemTitleEn, string? ItemImage,
    DateTime? RentalStartDate, DateTime? RentalEndDate,
    string CheckType, DateTime CreatedAt
);

// ── CREATE VERIFICATION ───────────────────────────────────────────────────────

public record CreateVerificationCommand(
    Guid ItemId,
    Guid? RentalId,
    string CheckType,   // before_rent | after_return
    string Status,      // pending | approved | rejected
    string? Notes
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

    public CreateVerificationCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
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

        var verification = new ItemVerification
        {
            ItemId = request.ItemId,
            ExpertId = _currentUser.Id.Value,
            RentalId = request.RentalId,
            CheckType = checkType,
            Status = status,
            Notes = request.Notes,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.ItemVerifications.Add(verification);
        await _context.SaveChangesAsync(ct);
        return new CreateVerificationResponse(true, null, verification.Id, verification.Status.ToString());
    }
}

// ── GET VERIFICATIONS ─────────────────────────────────────────────────────────

public record GetVerificationsQuery(Guid ItemId) : IRequest<GetVerificationsResponse>;
public record GetVerificationsResponse(bool Success, string? Error, List<VerificationDto>? Verifications);

public class GetVerificationsQueryHandler : IRequestHandler<GetVerificationsQuery, GetVerificationsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetVerificationsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetVerificationsResponse> Handle(GetVerificationsQuery request, CancellationToken ct)
    {
        var item = await _context.Items.FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);
        if (item == null) return new GetVerificationsResponse(false, "Item not found.", null);

        var verifications = await _context.ItemVerifications
            .Include(v => v.Expert)
            .Where(v => v.ItemId == request.ItemId)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new VerificationDto(
                v.Id, v.CheckType.ToString(), v.Status.ToString(), v.Notes,
                v.Expert != null ? v.Expert.FirstName : null,
                v.CreatedAt
            ))
            .ToListAsync(ct);

        return new GetVerificationsResponse(true, null, verifications);
    }
}

// ── GET EXPERT ASSIGNED ───────────────────────────────────────────────────────

public record GetExpertAssignedQuery : IRequest<GetExpertAssignedResponse>;
public record GetExpertAssignedResponse(List<AssignedVerificationDto> Assignments);

public class GetExpertAssignedQueryHandler : IRequestHandler<GetExpertAssignedQuery, GetExpertAssignedResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetExpertAssignedQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetExpertAssignedResponse> Handle(GetExpertAssignedQuery request, CancellationToken ct)
    {
        var assignments = await _context.ItemVerifications
            .Include(v => v.Item).ThenInclude(i => i.Images)
            .Include(v => v.Rental)
            .Where(v => v.ExpertId == _currentUser.Id!.Value && v.Status == VerificationStatus.Pending)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new AssignedVerificationDto(
                v.Id,
                v.Item.TitleAr,
                v.Item.TitleEn,
                v.Item.Images.Where(i => i.IsPrimary).Select(i => i.Image.StoragePath).FirstOrDefault()
                    ?? v.Item.Images.Select(i => i.Image.StoragePath).FirstOrDefault(),
                v.Rental != null ? v.Rental.StartDate : null,
                v.Rental != null ? v.Rental.EndDate : null,
                v.CheckType.ToString(),
                v.CreatedAt
            ))
            .ToListAsync(ct);

        return new GetExpertAssignedResponse(assignments);
    }
}
