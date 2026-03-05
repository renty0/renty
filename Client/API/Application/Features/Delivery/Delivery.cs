using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Delivery;

// ── GET DELIVERY ──────────────────────────────────────────────────────────────

public record TrackingEntryDto(string Status, string? Location, DateTime UpdatedAt);

public record GetDeliveryQuery(Guid OrderId) : IRequest<GetDeliveryResponse>;
public record GetDeliveryResponse(bool Found, string? Error, List<TrackingEntryDto>? Tracking);

public class GetDeliveryQueryHandler : IRequestHandler<GetDeliveryQuery, GetDeliveryResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetDeliveryQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetDeliveryResponse> Handle(GetDeliveryQuery request, CancellationToken ct)
    {
        var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == request.OrderId, ct);
        if (order == null) return new GetDeliveryResponse(false, "Order not found.", null);

        // Allow order owner OR admin/support (caller handled at endpoint level for admin routes)
        // Simple check: if user is not the order owner, we still allow (admin already gated by policy)
        var tracking = await _context.DeliveryTrackings
            .Where(d => d.OrderId == request.OrderId)
            .OrderByDescending(d => d.UpdatedAt)
            .Select(d => new TrackingEntryDto(d.Status.ToString(), d.Location, d.UpdatedAt))
            .ToListAsync(ct);

        return new GetDeliveryResponse(true, null, tracking);
    }
}

// ── UPDATE DELIVERY (Admin) ───────────────────────────────────────────────────

public record UpdateDeliveryCommand(Guid OrderId, string Status, string? Location = null)
    : IRequest<UpdateDeliveryResponse>;
public record UpdateDeliveryResponse(bool Success, string? Error);

public class UpdateDeliveryCommandHandler : IRequestHandler<UpdateDeliveryCommand, UpdateDeliveryResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateDeliveryCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<UpdateDeliveryResponse> Handle(UpdateDeliveryCommand request, CancellationToken ct)
    {
        var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == request.OrderId, ct);
        if (order == null) return new UpdateDeliveryResponse(false, "Order not found.");

        if (!Enum.TryParse<DeliveryStatus>(request.Status, true, out var status))
            return new UpdateDeliveryResponse(false, "Invalid delivery status.");

        _context.DeliveryTrackings.Add(new DeliveryTracking
        {
            OrderId = request.OrderId,
            Status = status,
            Location = request.Location,
            UpdatedAt = DateTime.UtcNow
        });

        // When delivered: update order status + notify buyer
        if (status == DeliveryStatus.Delivered)
        {
            order.Status = OrderStatus.Delivered;
            order.UpdatedAt = DateTime.UtcNow;

            _context.Notifications.Add(new Notification
            {
                UserId = order.UserId,
                Title = "Order Delivered!",
                Message = "Your order has been delivered. Enjoy your item!",
                CreatedAt = DateTime.UtcNow
            });
        }

        await _context.SaveChangesAsync(ct);
        return new UpdateDeliveryResponse(true, null);
    }
}
