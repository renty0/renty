using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Items;

public record DeleteItemCommand(Guid ItemId) : IRequest<DeleteItemResponse>;

public record DeleteItemResponse(bool Success, string? Error);

public class DeleteItemCommandHandler : IRequestHandler<DeleteItemCommand, DeleteItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public DeleteItemCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<DeleteItemResponse> Handle(DeleteItemCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new DeleteItemResponse(false, "Unauthorized.");

        var item = await _context.Items
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null)
            return new DeleteItemResponse(false, "Item not found.");

        if (item.OwnerId != _currentUser.Id.Value)
            return new DeleteItemResponse(false, "Forbidden. You do not own this item.");

        if (item.Status == NewItemStatus.Rented)
            return new DeleteItemResponse(false, "Cannot remove an item while it is rented.");

        // Soft delete
        item.Status = NewItemStatus.Removed;
        item.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(ct);

        return new DeleteItemResponse(true, null);
    }
}
