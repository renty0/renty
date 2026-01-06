using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentableItems;

public record UpdateItemStatusCommand(long Id, ItemStatus Status) : IRequest<UpdateItemStatusResponse>;

public record UpdateItemStatusResponse(
    bool Success,
    string? Message
);

public class UpdateItemStatusCommandValidator : AbstractValidator<UpdateItemStatusCommand>
{
    public UpdateItemStatusCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid item ID.");

        RuleFor(x => x.Status)
            .IsInEnum().WithMessage("Invalid status.");
    }
}

public class UpdateItemStatusCommandHandler : IRequestHandler<UpdateItemStatusCommand, UpdateItemStatusResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public UpdateItemStatusCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<UpdateItemStatusResponse> Handle(UpdateItemStatusCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new UpdateItemStatusResponse(false, "User not authenticated.");
        }

        var item = await _context.RentableItems
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (item == null)
        {
            return new UpdateItemStatusResponse(false, "Item not found.");
        }

        if (item.OwnerId != _currentUser.Id.Value)
        {
            return new UpdateItemStatusResponse(false, "You can only update your own items.");
        }

        // Check if status transition is valid
        if (item.Status == ItemStatus.Rented && request.Status != ItemStatus.Available && request.Status != ItemStatus.Unavailable)
        {
            return new UpdateItemStatusResponse(false, "Cannot change status of rented item except to Available or Unavailable.");
        }

        item.Status = request.Status;
        await _context.SaveChangesAsync(cancellationToken);

        return new UpdateItemStatusResponse(true, $"Item status updated to {request.Status}.");
    }
}
