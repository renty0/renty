using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentableItems;

public record DeleteRentableItemCommand(long Id) : IRequest<DeleteRentableItemResponse>;

public record DeleteRentableItemResponse(
    bool Success,
    string? Message
);

public class DeleteRentableItemCommandValidator : AbstractValidator<DeleteRentableItemCommand>
{
    public DeleteRentableItemCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid item ID.");
    }
}

public class DeleteRentableItemCommandHandler : IRequestHandler<DeleteRentableItemCommand, DeleteRentableItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public DeleteRentableItemCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<DeleteRentableItemResponse> Handle(DeleteRentableItemCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new DeleteRentableItemResponse(false, "User not authenticated.");
        }

        var item = await _context.RentableItems
            .Include(r => r.RentRequests)
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (item == null)
        {
            return new DeleteRentableItemResponse(false, "Item not found.");
        }

        if (item.OwnerId != _currentUser.Id.Value)
        {
            return new DeleteRentableItemResponse(false, "You can only delete your own items.");
        }

        // Check for active rent requests
        var hasActiveRequests = item.RentRequests.Any(r =>
            r.Status == RentRequestStatus.Pending ||
            r.Status == RentRequestStatus.Approved ||
            r.Status == RentRequestStatus.Active);

        if (hasActiveRequests)
        {
            return new DeleteRentableItemResponse(false, "Cannot delete item with active rent requests.");
        }

        // Soft delete by archiving
        item.Status = ItemStatus.Archived;
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteRentableItemResponse(true, "Item archived successfully.");
    }
}
