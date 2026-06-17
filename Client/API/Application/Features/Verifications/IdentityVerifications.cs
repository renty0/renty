using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Verifications;

// ── PHONE VERIFICATION ────────────────────────────────────────────────────────

public record RequestPhoneVerificationCommand(string PhoneNumber) : IRequest<RequestPhoneVerificationResponse>;
public record RequestPhoneVerificationResponse(bool Success, string? Error, string? SimulatedOtp);

public class RequestPhoneVerificationCommandHandler : IRequestHandler<RequestPhoneVerificationCommand, RequestPhoneVerificationResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public RequestPhoneVerificationCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RequestPhoneVerificationResponse> Handle(RequestPhoneVerificationCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new RequestPhoneVerificationResponse(false, "Unauthorized.", null);

        // Simulation: In a real world, we would call an SMS provider (like Twilio or a local MENA provider)
        // and temporarily store the OTP in a distributed cache (Redis) with an expiration.
        var simulatedOtp = "1234";

        return new RequestPhoneVerificationResponse(true, null, simulatedOtp);
    }
}


public record ConfirmPhoneVerificationCommand(string Code) : IRequest<ConfirmPhoneVerificationResponse>;
public record ConfirmPhoneVerificationResponse(bool Success, string? Error);

public class ConfirmPhoneVerificationCommandHandler : IRequestHandler<ConfirmPhoneVerificationCommand, ConfirmPhoneVerificationResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public ConfirmPhoneVerificationCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<ConfirmPhoneVerificationResponse> Handle(ConfirmPhoneVerificationCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new ConfirmPhoneVerificationResponse(false, "Unauthorized.");

        // Simulate reading from Cache. We will accept "1234" for the simulation.
        if (request.Code != "1234")
        {
            return new ConfirmPhoneVerificationResponse(false, "Invalid or expired OTP.");
        }

        // Must fetch the user from Identity Manager, but we can query DbContext directly since it inherits IdentityDbContext.
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);
        if (user == null)
            return new ConfirmPhoneVerificationResponse(false, "User not found.");

        user.PhoneVerified = true;
        await _context.SaveChangesAsync(ct);

        return new ConfirmPhoneVerificationResponse(true, null);
    }
}

// ── ID DOCUMENT UPLOAD ────────────────────────────────────────────────────────

public record UploadIdVerificationCommand(string FrontImageUrl, string BackImageUrl) : IRequest<UploadIdVerificationResponse>;
public record UploadIdVerificationResponse(bool Success, string? Error, Guid? IdVerificationId);

public class UploadIdVerificationCommandValidator : AbstractValidator<UploadIdVerificationCommand>
{
    public UploadIdVerificationCommandValidator()
    {
        RuleFor(x => x.FrontImageUrl).NotEmpty();
        RuleFor(x => x.BackImageUrl).NotEmpty();
    }
}

public class UploadIdVerificationCommandHandler : IRequestHandler<UploadIdVerificationCommand, UploadIdVerificationResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;
    private readonly IRoleService _roleService;

    public UploadIdVerificationCommandHandler(
        IApplicationDbContext context,
        IUser currentUser,
        INotificationSender notifier,
        IRoleService roleService)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
        _roleService = roleService;
    }

    public async Task<UploadIdVerificationResponse> Handle(UploadIdVerificationCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new UploadIdVerificationResponse(false, "Unauthorized.", null);

        // Check if there is already a pending verification
        var existingPending = await _context.IdVerifications
            .AnyAsync(idv => idv.UserId == _currentUser.Id.Value && idv.Status == VerificationStatus.Pending, ct);
        
        if (existingPending)
            return new UploadIdVerificationResponse(false, "You already have a pending ID verification request.", null);

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);
        if (user == null)
            return new UploadIdVerificationResponse(false, "User not found.", null);

        var verification = new IdVerification
        {
            UserId = _currentUser.Id.Value,
            FrontImageUrl = request.FrontImageUrl,
            BackImageUrl = request.BackImageUrl,
            Status = VerificationStatus.Pending,
            CreatedAt = DateTimeOffset.UtcNow
        };

        _context.IdVerifications.Add(verification);
        await _context.SaveChangesAsync(ct);

        // Notify admins about the new ID verification request
        try
        {
            var adminIds = await _roleService.GetUserIdsInRoleAsync("Admin");
            var superAdminIds = await _roleService.GetUserIdsInRoleAsync("SuperAdmin");
            var recipientIds = adminIds.Concat(superAdminIds).Distinct().ToList();
            if (recipientIds.Count > 0)
            {
                await _notifier.SendToUsersAsync(
                    recipientIds,
                    "New ID Verification Request",
                    $"{user.FullName} has submitted their ID for verification.",
                    "system",
                    "/admin/id-verifications",
                    ct);
            }
        }
        catch
        {
            // Do not block ID submission if notification fails
        }

        return new UploadIdVerificationResponse(true, null, verification.Id);
    }
}

// ── ADMIN REVIEW ID VERIFICATION ──────────────────────────────────────────────

public record ReviewIdVerificationCommand(Guid IdVerificationId, string Status, string? RejectionReason) : IRequest<ReviewIdVerificationResponse>;
public record ReviewIdVerificationResponse(bool Success, string? Error);

public class ReviewIdVerificationCommandValidator : AbstractValidator<ReviewIdVerificationCommand>
{
    public ReviewIdVerificationCommandValidator()
    {
        RuleFor(x => x.IdVerificationId).NotEmpty();
        RuleFor(x => x.Status)
            .Must(s => s == "approved" || s == "rejected")
            .WithMessage("Status must be 'approved' or 'rejected'.");
    }
}

public class ReviewIdVerificationCommandHandler : IRequestHandler<ReviewIdVerificationCommand, ReviewIdVerificationResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public ReviewIdVerificationCommandHandler(
        IApplicationDbContext context,
        IUser currentUser,
        INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<ReviewIdVerificationResponse> Handle(ReviewIdVerificationCommand request, CancellationToken ct)
    {
        var idv = await _context.IdVerifications
            .Include(v => v.User)
            .FirstOrDefaultAsync(v => v.Id == request.IdVerificationId, ct);
        
        if (idv == null) return new ReviewIdVerificationResponse(false, "Record not found.");

        Enum.TryParse<VerificationStatus>(request.Status, true, out var newStatus);
        
        idv.Status = newStatus;
        idv.ReviewedById = _currentUser.Id!.Value;
        idv.ReviewedAt = DateTimeOffset.UtcNow;

        if (newStatus == VerificationStatus.Rejected)
        {
            idv.RejectionReason = request.RejectionReason;
            idv.User.IdVerified = false;
        }
        else if (newStatus == VerificationStatus.Approved)
        {
            idv.User.IdVerified = true;
            idv.RejectionReason = null;
        }

        await _context.SaveChangesAsync(ct);

        // Notify the user about the decision
        try
        {
            if (newStatus == VerificationStatus.Approved)
            {
                await _notifier.SendToUserAsync(
                    idv.UserId,
                    "Identity Verified ✅",
                    "Your identity verification request has been approved.",
                    "system",
                    "/profile",
                    ct);
            }
            else if (newStatus == VerificationStatus.Rejected)
            {
                await _notifier.SendToUserAsync(
                    idv.UserId,
                    "Identity Verification Rejected ❌",
                    $"Your ID verification was rejected: {request.RejectionReason}",
                    "system",
                    "/profile",
                    ct);
            }
        }
        catch
        {
            // Do not block database update if notification fails
        }

        return new ReviewIdVerificationResponse(true, null);
    }
}

// ── ADMIN ID VERIFICATIONS QUERIES ───────────────────────────────────────────

public record AdminIdVerificationDto(
    Guid Id,
    long UserId,
    string UserName,
    string UserEmail,
    string Status,
    string? RejectionReason,
    string FrontImageUrl,
    string BackImageUrl,
    DateTimeOffset CreatedAt,
    DateTimeOffset? ReviewedAt
);

public record GetAdminIdVerificationsQuery(string? StatusFilter, int Page, int Limit) : IRequest<GetAdminIdVerificationsResponse>;
public record GetAdminIdVerificationsResponse(List<AdminIdVerificationDto> Verifications, int Total, int Page, int Pages);

public class GetAdminIdVerificationsQueryHandler : IRequestHandler<GetAdminIdVerificationsQuery, GetAdminIdVerificationsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetAdminIdVerificationsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetAdminIdVerificationsResponse> Handle(GetAdminIdVerificationsQuery request, CancellationToken ct)
    {
        var query = _context.IdVerifications
            .Include(v => v.User)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(request.StatusFilter) && request.StatusFilter != "All")
        {
            if (Enum.TryParse<VerificationStatus>(request.StatusFilter, true, out var status))
            {
                query = query.Where(v => v.Status == status);
            }
        }

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var list = await query
            .OrderByDescending(v => v.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(v => new AdminIdVerificationDto(
                v.Id,
                v.UserId,
                v.User.FullName,
                v.User.Email ?? string.Empty,
                v.Status.ToString(),
                v.RejectionReason,
                v.FrontImageUrl,
                v.BackImageUrl,
                v.CreatedAt,
                v.ReviewedAt
            ))
            .ToListAsync(ct);

        return new GetAdminIdVerificationsResponse(list, total, request.Page, pages);
    }
}

public record GetAdminIdVerificationByIdQuery(Guid Id) : IRequest<AdminIdVerificationDto?>;

public class GetAdminIdVerificationByIdQueryHandler : IRequestHandler<GetAdminIdVerificationByIdQuery, AdminIdVerificationDto?>
{
    private readonly IApplicationDbContext _context;

    public GetAdminIdVerificationByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<AdminIdVerificationDto?> Handle(GetAdminIdVerificationByIdQuery request, CancellationToken ct)
    {
        var v = await _context.IdVerifications
            .Include(v => v.User)
            .FirstOrDefaultAsync(x => x.Id == request.Id, ct);

        if (v == null) return null;

        return new AdminIdVerificationDto(
            v.Id,
            v.UserId,
            v.User.FullName,
            v.User.Email ?? string.Empty,
            v.Status.ToString(),
            v.RejectionReason,
            v.FrontImageUrl,
            v.BackImageUrl,
            v.CreatedAt,
            v.ReviewedAt
        );
    }
}
