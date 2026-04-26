using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Items;

// ── Add Reminder ──────────────────────────────────────────────────────────────

public record AddReminderCommand(Guid ItemId) : IRequest<ReminderResponse>;
public record ReminderResponse(bool Success, string? Error, bool IsReminded);

public class AddReminderCommandHandler : IRequestHandler<AddReminderCommand, ReminderResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public AddReminderCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<ReminderResponse> Handle(AddReminderCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new ReminderResponse(false, "Unauthorized.", false);

        var item = await _context.Items.FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);
        if (item == null) return new ReminderResponse(false, "Item not found.", false);
        if (item.OwnerId == _currentUser.Id.Value) return new ReminderResponse(false, "Cannot remind on your own item.", false);

        var existing = await _context.ItemReminders
            .FirstOrDefaultAsync(r => r.UserId == _currentUser.Id.Value && r.ItemId == request.ItemId, ct);

        if (existing != null) return new ReminderResponse(true, null, true); // already set

        _context.ItemReminders.Add(new ItemReminder
        {
            UserId = _currentUser.Id.Value,
            ItemId = request.ItemId,
            CreatedAt = DateTime.UtcNow
        });
        await _context.SaveChangesAsync(ct);
        return new ReminderResponse(true, null, true);
    }
}

// ── Remove Reminder ───────────────────────────────────────────────────────────

public record RemoveReminderCommand(Guid ItemId) : IRequest<ReminderResponse>;

public class RemoveReminderCommandHandler : IRequestHandler<RemoveReminderCommand, ReminderResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public RemoveReminderCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<ReminderResponse> Handle(RemoveReminderCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new ReminderResponse(false, "Unauthorized.", false);

        var reminder = await _context.ItemReminders
            .FirstOrDefaultAsync(r => r.UserId == _currentUser.Id.Value && r.ItemId == request.ItemId, ct);

        if (reminder == null) return new ReminderResponse(true, null, false);

        _context.ItemReminders.Remove(reminder);
        await _context.SaveChangesAsync(ct);
        return new ReminderResponse(true, null, false);
    }
}

// ── Check Reminder ────────────────────────────────────────────────────────────

public record GetReminderStatusQuery(Guid ItemId) : IRequest<ReminderStatusResponse>;
public record ReminderStatusResponse(bool IsReminded);

public class GetReminderStatusQueryHandler : IRequestHandler<GetReminderStatusQuery, ReminderStatusResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetReminderStatusQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<ReminderStatusResponse> Handle(GetReminderStatusQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null) return new ReminderStatusResponse(false);

        var exists = await _context.ItemReminders
            .AnyAsync(r => r.UserId == _currentUser.Id.Value && r.ItemId == request.ItemId, ct);

        return new ReminderStatusResponse(exists);
    }
}
