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

    public UploadIdVerificationCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
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

    public ReviewIdVerificationCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
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
        }
        else if (newStatus == VerificationStatus.Approved)
        {
            idv.User.IdVerified = true;
        }

        await _context.SaveChangesAsync(ct);
        return new ReviewIdVerificationResponse(true, null);
    }
}
