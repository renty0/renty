using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace Application.Features.Items;

public record DeleteItemCommand(Guid ItemId) : IRequest<DeleteItemResponse>;

public record DeleteItemResponse(bool Success, string? Error, bool IsPermanentDelete = false);

public class DeleteItemCommandHandler : IRequestHandler<DeleteItemCommand, DeleteItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public DeleteItemCommandHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<DeleteItemResponse> Handle(DeleteItemCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new DeleteItemResponse(false, "Unauthorized.");

        var item = await _context.Items
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null)
            return new DeleteItemResponse(false, "Item not found.");

        var isAdmin = _httpContextAccessor.HttpContext?.User?.IsInRole("Admin") ?? false;
        if (!isAdmin && item.OwnerId != _currentUser.Id.Value)
            return new DeleteItemResponse(false, "Forbidden. You do not own this item.");

        if (item.Status == NewItemStatus.Rented)
            return new DeleteItemResponse(false, "Cannot remove an item while it is rented.");

        if (item.Status == NewItemStatus.Removed)
        {
            var hasRentals = await _context.Rentals.AnyAsync(r => r.ItemId == item.Id, ct);
            if (hasRentals)
                return new DeleteItemResponse(false, "Cannot permanently delete an item with rental history.");

            var pricings = await _context.ItemPricings.Where(p => p.ItemId == item.Id).ToListAsync(ct);
            var images = await _context.ItemImages.Where(img => img.ItemId == item.Id).ToListAsync(ct);
            var favorites = await _context.Favorites.Where(f => f.ItemId == item.Id).ToListAsync(ct);
            var reminders = await _context.ItemReminders.Where(r => r.ItemId == item.Id).ToListAsync(ct);

            if (pricings.Count > 0) _context.ItemPricings.RemoveRange(pricings);
            if (images.Count > 0) _context.ItemImages.RemoveRange(images);
            if (favorites.Count > 0) _context.Favorites.RemoveRange(favorites);
            if (reminders.Count > 0) _context.ItemReminders.RemoveRange(reminders);

            _context.Items.Remove(item);
            await _context.SaveChangesAsync(ct);
            return new DeleteItemResponse(true, null, true);
        }

        item.Status = NewItemStatus.Removed;
        item.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);
        return new DeleteItemResponse(true, null, false);
    }
}

public record ReactivateItemCommand(Guid ItemId) : IRequest<DeleteItemResponse>;

public class ReactivateItemCommandHandler : IRequestHandler<ReactivateItemCommand, DeleteItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public ReactivateItemCommandHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<DeleteItemResponse> Handle(ReactivateItemCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new DeleteItemResponse(false, "Unauthorized.");

        var item = await _context.Items.FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);
        if (item == null)
            return new DeleteItemResponse(false, "Item not found.");

        var isAdmin = _httpContextAccessor.HttpContext?.User?.IsInRole("Admin") ?? false;
        if (!isAdmin && item.OwnerId != _currentUser.Id.Value)
            return new DeleteItemResponse(false, "Forbidden. You do not own this item.");

        if (item.Status != NewItemStatus.Removed)
            return new DeleteItemResponse(false, "Only removed items can be reactivated.");

        item.Status = NewItemStatus.Available;
        item.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);
        return new DeleteItemResponse(true, null);
    }
}
