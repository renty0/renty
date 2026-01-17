using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record CancelRentRequestCommand(
    long RequestId,
    string? CancellationReason
) : IRequest<CancelRentRequestResponse>;

public record CancelRentRequestResponse(
    bool Success,
    string? Message
);

public class CancelRentRequestCommandValidator : AbstractValidator<CancelRentRequestCommand>
{
    public CancelRentRequestCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");

        RuleFor(x => x.CancellationReason)
            .MaximumLength(500).WithMessage("Cancellation reason must not exceed 500 characters.");
    }
}

public class CancelRentRequestCommandHandler : IRequestHandler<CancelRentRequestCommand, CancelRentRequestResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CancelRentRequestCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CancelRentRequestResponse> Handle(CancelRentRequestCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new CancelRentRequestResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new CancelRentRequestResponse(false, "Request not found.");
        }

        if (rentRequest.RenterId != _currentUser.Id.Value)
        {
            return new CancelRentRequestResponse(false, "You can only cancel your own requests.");
        }

        if (rentRequest.Status != RentRequestStatus.Pending && rentRequest.Status != RentRequestStatus.Approved)
        {
            return new CancelRentRequestResponse(false, "This request cannot be cancelled.");
        }

        rentRequest.Status = RentRequestStatus.Cancelled;
        rentRequest.CancellationReason = request.CancellationReason;
        rentRequest.CancelledAt = DateTimeOffset.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return new CancelRentRequestResponse(true, "Request cancelled successfully.");
    }
}
