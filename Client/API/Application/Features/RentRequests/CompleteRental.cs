using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record CompleteRentalCommand(long RequestId) : IRequest<CompleteRentalResponse>;

public record CompleteRentalResponse(
    bool Success,
    string? Message
);

public class CompleteRentalCommandValidator : AbstractValidator<CompleteRentalCommand>
{
    public CompleteRentalCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");
    }
}

public class CompleteRentalCommandHandler : IRequestHandler<CompleteRentalCommand, CompleteRentalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CompleteRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CompleteRentalResponse> Handle(CompleteRentalCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new CompleteRentalResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new CompleteRentalResponse(false, "Request not found.");
        }

        if (rentRequest.RentableItem.OwnerId != _currentUser.Id.Value)
        {
            return new CompleteRentalResponse(false, "You can only complete rentals for your own items.");
        }

        if (rentRequest.Status != RentRequestStatus.Active)
        {
            return new CompleteRentalResponse(false, "Only active rentals can be completed.");
        }

        rentRequest.Status = RentRequestStatus.Completed;
        rentRequest.RentableItem.Status = ItemStatus.Available;

        await _context.SaveChangesAsync(cancellationToken);

        return new CompleteRentalResponse(true, "Rental completed successfully.");
    }
}
