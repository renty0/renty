using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Orders;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record OrderItemInputDto(Guid ItemId, int Quantity);
public record OrderListDto(Guid Id, decimal? TotalAmount, string Status, DateTime CreatedAt, int ItemCount);
public record OrderItemDetailDto(Guid ItemId, string Title, int Quantity, decimal PriceAtTime, string? PrimaryImage);
public record OrderDetailDto(
    Guid Id, decimal? TotalAmount, string Status, DateTime CreatedAt,
    List<OrderItemDetailDto> Items,
    string? PaymentStatus, string? DeliveryStatus
);

// ── CREATE ORDER ──────────────────────────────────────────────────────────────

public record CreateOrderCommand(List<OrderItemInputDto> Items) : IRequest<CreateOrderResponse>;
public record CreateOrderResponse(bool Success, string? Error, Guid? OrderId, decimal? TotalAmount, string Status = "pending");

public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.Items).NotEmpty().WithMessage("At least one item is required.");
        RuleForEach(x => x.Items).ChildRules(i =>
        {
            i.RuleFor(x => x.ItemId).NotEmpty();
            i.RuleFor(x => x.Quantity).GreaterThan(0);
        });
    }
}

public class CreateOrderCommandHandler : IRequestHandler<CreateOrderCommand, CreateOrderResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CreateOrderCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreateOrderResponse> Handle(CreateOrderCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateOrderResponse(false, "Unauthorized.", null, null);

        var itemIds = request.Items.Select(i => i.ItemId).ToList();
        var items = await _context.Items
            .Include(i => i.Pricing)
            .Where(i => itemIds.Contains(i.Id))
            .ToListAsync(ct);

        // Validate all items available
        foreach (var i in request.Items)
        {
            var item = items.FirstOrDefault(x => x.Id == i.ItemId);
            if (item == null) return new CreateOrderResponse(false, $"Item {i.ItemId} not found.", null, null);
            if (item.Status != NewItemStatus.Available)
                return new CreateOrderResponse(false, $"Item '{item.TitleEn}' is not available.", null, null);
        }

        var order = new Order
        {
            UserId = _currentUser.Id.Value,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.Orders.Add(order);

        decimal total = 0;
        foreach (var i in request.Items)
        {
            var item = items.First(x => x.Id == i.ItemId);
            var dailyPrice = item.Pricing.FirstOrDefault(p => p.PricingType == "daily")?.Price ?? 0;
            var lineTotal = dailyPrice * i.Quantity;
            total += lineTotal;

            order.Items.Add(new OrderItem
            {
                OrderId = order.Id,
                ItemId = i.ItemId,
                Quantity = i.Quantity,
                PriceAtTime = dailyPrice
            });
        }

        order.TotalAmount = total;
        await _context.SaveChangesAsync(ct);
        return new CreateOrderResponse(true, null, order.Id, total);
    }
}

// ── GET ORDERS ────────────────────────────────────────────────────────────────

public record GetOrdersQuery : IRequest<GetOrdersResponse>;
public record GetOrdersResponse(List<OrderListDto> Orders);

public class GetOrdersQueryHandler : IRequestHandler<GetOrdersQuery, GetOrdersResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetOrdersQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetOrdersResponse> Handle(GetOrdersQuery request, CancellationToken ct)
    {
        var orders = await _context.Orders
            .Where(o => o.UserId == _currentUser.Id!.Value)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => new OrderListDto(o.Id, o.TotalAmount, o.Status.ToString(), o.CreatedAt, o.Items.Count))
            .ToListAsync(ct);

        return new GetOrdersResponse(orders);
    }
}

// ── GET ORDER BY ID ───────────────────────────────────────────────────────────

public record GetOrderByIdQuery(Guid OrderId) : IRequest<GetOrderByIdResponse>;
public record GetOrderByIdResponse(bool Found, string? Error, OrderDetailDto? Order);

public class GetOrderByIdQueryHandler : IRequestHandler<GetOrderByIdQuery, GetOrderByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetOrderByIdQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetOrderByIdResponse> Handle(GetOrderByIdQuery request, CancellationToken ct)
    {
        var order = await _context.Orders
            .Include(o => o.Items).ThenInclude(oi => oi.Item).ThenInclude(i => i.Images)
            .Include(o => o.Payments)
            .Include(o => o.DeliveryTrackings)
            .FirstOrDefaultAsync(o => o.Id == request.OrderId, ct);

        if (order == null) return new GetOrderByIdResponse(false, "Order not found.", null);
        if (order.UserId != _currentUser.Id!.Value)
            return new GetOrderByIdResponse(false, "Forbidden.", null);

        var dto = new OrderDetailDto(
            order.Id, order.TotalAmount, order.Status.ToString(), order.CreatedAt,
            order.Items.Select(oi => new OrderItemDetailDto(
                oi.ItemId, oi.Item.TitleEn, oi.Quantity, oi.PriceAtTime,
                oi.Item.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath ?? oi.Item.Images.FirstOrDefault()?.Image?.StoragePath
            )).ToList(),
            order.Payments.OrderByDescending(p => p.CreatedAt).FirstOrDefault()?.Status.ToString(),
            order.DeliveryTrackings.OrderByDescending(d => d.UpdatedAt).FirstOrDefault()?.Status.ToString()
        );

        return new GetOrderByIdResponse(true, null, dto);
    }
}
