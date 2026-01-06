using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record StartRentalCommand(long RequestId) : IRequest<StartRentalResponse>;

public record StartRentalResponse(
    bool Success,
    string? Message
);

public class StartRentalCommandValidator : AbstractValidator<StartRentalCommand>
{
    public StartRentalCommandValidator()
    {
        RuleFor(x => x.RequestId)
            .GreaterThan(0).WithMessage("Invalid request ID.");
    }
}

public class StartRentalCommandHandler : IRequestHandler<StartRentalCommand, StartRentalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public StartRentalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<StartRentalResponse> Handle(StartRentalCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new StartRentalResponse(false, "User not authenticated.");
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .FirstOrDefaultAsync(r => r.Id == request.RequestId, cancellationToken);

        if (rentRequest == null)
        {
            return new StartRentalResponse(false, "Request not found.");
        }

        if (rentRequest.RentableItem.OwnerId != _currentUser.Id.Value)
        {
            return new StartRentalResponse(false, "You can only start rentals for your own items.");
        }

        if (rentRequest.Status != RentRequestStatus.Approved)
        {
            return new StartRentalResponse(false, "Only approved requests can be started.");
        }

        rentRequest.Status = RentRequestStatus.Active;
        rentRequest.RentableItem.Status = ItemStatus.Rented;

        await _context.SaveChangesAsync(cancellationToken);

        return new StartRentalResponse(true, "Rental started successfully.");
    }
}
