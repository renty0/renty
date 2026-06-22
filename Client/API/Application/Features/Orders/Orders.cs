using Application.Common.Interfaces;
using Application.Common;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Orders;

public record OrderItemInputDto(Guid ItemId, int Quantity);
public record OrderListDto(Guid Id, decimal? TotalAmount, string Status, DateTime CreatedAt, int ItemCount, string? PrimaryImageUrl);
public record OrderItemDetailDto(Guid ItemId, string Title, int Quantity, decimal PriceAtTime, string? PrimaryImageUrl);
public record OrderDetailDto(
    Guid Id, decimal? TotalAmount, string Status, DateTime CreatedAt,
    List<OrderItemDetailDto> Items,
    string? PaymentStatus, string? DeliveryStatus
);

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
    private readonly IFraudDetectionService _fraudService;
    private readonly INotificationSender _notifier;

    public CreateOrderCommandHandler(
        IApplicationDbContext context,
        IUser currentUser,
        IFraudDetectionService fraudService,
        INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _fraudService = fraudService;
        _notifier = notifier;
    }

    public async Task<CreateOrderResponse> Handle(CreateOrderCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateOrderResponse(false, "Unauthorized.", null, null);

        var maintenanceSetting = await _context.SystemSettings.FirstOrDefaultAsync(s => s.Key == "MaintenanceMode", ct);
        if (maintenanceSetting != null && maintenanceSetting.Value == "true")
        {
            return new CreateOrderResponse(false, "Platform is currently under maintenance. New orders are temporarily disabled.", null, null);
        }

        // Evaluate fraud potential before finishing
        // (Simplified: we'll call it after save for velocity check)

        var itemIds = request.Items.Select(i => i.ItemId).ToList();
        var items = await _context.Items
            .Include(i => i.Pricing)
            .Where(i => itemIds.Contains(i.Id))
            .ToListAsync(ct);
        foreach (var i in request.Items)
        {
            var item = items.FirstOrDefault(x => x.Id == i.ItemId);
            if (item == null) return new CreateOrderResponse(false, $"Item {i.ItemId} not found.", null, null);
            if (item.Status != NewItemStatus.Available)
                return new CreateOrderResponse(false, $"Item '{item.TitleEn}' is not available.", null, null);
        }

        decimal total = 0;
        foreach (var i in request.Items)
        {
            var item = items.First(x => x.Id == i.ItemId);
            var dailyPrice = item.Pricing.FirstOrDefault(p => p.PricingType == "daily")?.Price ?? 0;
            var lineTotal = dailyPrice * i.Quantity;
            total += lineTotal;
        }

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);
        if (user == null) return new CreateOrderResponse(false, "User not found.", null, null);

        if (user.WalletBalance < total)
        {
            return new CreateOrderResponse(false, "Insufficient balance. Please recharge your wallet.", null, null);
        }

        var order = new Order
        {
            UserId = _currentUser.Id.Value,
            Status = OrderStatus.Paid,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            TotalAmount = total
        };
        _context.Orders.Add(order);

        foreach (var i in request.Items)
        {
            var item = items.First(x => x.Id == i.ItemId);
            var dailyPrice = item.Pricing.FirstOrDefault(p => p.PricingType == "daily")?.Price ?? 0;
            order.Items.Add(new OrderItem
            {
                OrderId = order.Id,
                ItemId = i.ItemId,
                Quantity = i.Quantity,
                PriceAtTime = dailyPrice
            });
        }

        // Escrow Hold
        user.WalletBalance -= total;
        user.PendingBalance += total;

        _context.WalletTransactions.Add(new WalletTransaction
        {
            UserId = user.Id,
            Amount = -total, // Displayed as negative hold
            Type = TransactionType.EscrowHold,
            Description = $"Escrow hold for order {order.Id}",
            IsPending = true,
            CreatedAt = DateTimeOffset.UtcNow
        });

        // Also add a payment record to signify it was paid via Wallet
        var payment = new Payment
        {
            OrderId = order.Id,
            Amount = total,
            Method = PaymentMethod.Wallet,
            Status = PaymentStatus.Success,
            TransactionRef = Guid.NewGuid().ToString("N")[..16].ToUpper(),
            CreatedAt = DateTime.UtcNow
        };
        _context.Payments.Add(payment);

        await _context.SaveChangesAsync(ct);

        await _notifier.SendToUserAsync(
            user.Id,
            "Payment Confirmed",
            $"Your payment of {total:C} via Wallet has been confirmed.",
            "payment",
            $"/orders/{order.Id}",
            ct,
            "تأكيد الدفع",
            $"تم تأكيد دفعك بقيمة {total:C} عبر المحفظة."
        );

        // Run background fraud check
        _ = _fraudService.EvaluateOrderAsync(order.Id);

        // Notify item owner(s)
        try
        {
            var ownerIds = items.Select(i => i.OwnerId).Distinct().ToList();
            var title = "New Order";

            foreach (var ownerId in ownerIds)
            {
                // Avoid notifying the buyer if they order their own item (shouldn't happen, but safe)
                if (ownerId == _currentUser.Id.Value) continue;

            var ownerItems = items
                    .Where(i => i.OwnerId == ownerId)
                    .Select(i => i.TitleEn)
                    .Where(t => !string.IsNullOrWhiteSpace(t))
                    .Distinct()
                    .Take(3)
                    .ToList();

                var ownerItemsAr = items
                    .Where(i => i.OwnerId == ownerId)
                    .Select(i => i.TitleAr)
                    .Where(t => !string.IsNullOrWhiteSpace(t))
                    .Distinct()
                    .Take(3)
                    .ToList();

                var msg = ownerItems.Count switch
                {
                    0 => "You received a new order.",
                    1 => $"You received a new order for '{ownerItems[0]}'.",
                    _ => $"You received a new order for {ownerItems.Count} items."
                };

                var msgAr = ownerItemsAr.Count switch
                {
                    0 => "لديك طلب جديد.",
                    1 => $"لديك طلب جديد للمنتج '{ownerItemsAr[0]}'.",
                    _ => $"لديك طلب جديد يحتوي على {ownerItemsAr.Count} منتجات."
                };

                await _notifier.SendToUserAsync(
                    ownerId,
                    title,
                    msg,
                    "order",
                    actionUrl: $"/orders/{order.Id}",
                    ct: ct,
                    titleAr: "طلب جديد",
                    messageAr: msgAr);
            }
        }
        catch
        {
            // Notification failures shouldn't block order creation.
        }

        return new CreateOrderResponse(true, null, order.Id, total);
    }
}

public record GetOrdersQuery : IRequest<GetOrdersResponse>;
public record GetOrdersResponse(List<OrderListDto> Orders);

public class GetOrdersQueryHandler : IRequestHandler<GetOrdersQuery, GetOrdersResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

    public GetOrdersQueryHandler(IApplicationDbContext context, IUser currentUser, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetOrdersResponse> Handle(GetOrdersQuery request, CancellationToken ct)
    {
        var requestPath = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestPath != null ? $"{requestPath.Scheme}://{requestPath.Host}" : "";

        var orders = await _context.Orders
            .Where(o => o.UserId == _currentUser.Id!.Value)
            .OrderByDescending(o => o.CreatedAt)
            .Include(o => o.Items).ThenInclude(oi => oi.Item).ThenInclude(i => i.Images).ThenInclude(ii => ii.Image)
            .ToListAsync(ct);

        var dtos = orders.Select(o =>
        {
            var firstItem = o.Items.FirstOrDefault()?.Item;
            var storagePath = firstItem?.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath 
                             ?? firstItem?.Images.FirstOrDefault()?.Image?.StoragePath;
            
            var fullUrl = storagePath.ToAbsoluteUrl(baseUrl);

            return new OrderListDto(o.Id, o.TotalAmount, o.Status.ToString(), o.CreatedAt, o.Items.Count, fullUrl);
        }).ToList();

        return new GetOrdersResponse(dtos);
    }
}

public record GetOrderByIdQuery(Guid OrderId) : IRequest<GetOrderByIdResponse>;
public record GetOrderByIdResponse(bool Found, string? Error, OrderDetailDto? Order);

public class GetOrderByIdQueryHandler : IRequestHandler<GetOrderByIdQuery, GetOrderByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

    public GetOrderByIdQueryHandler(IApplicationDbContext context, IUser currentUser, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetOrderByIdResponse> Handle(GetOrderByIdQuery request, CancellationToken ct)
    {
        var order = await _context.Orders
            .Include(o => o.Items).ThenInclude(oi => oi.Item).ThenInclude(i => i.Images).ThenInclude(ii => ii.Image)
            .Include(o => o.Payments)
            .Include(o => o.DeliveryTrackings)
            .FirstOrDefaultAsync(o => o.Id == request.OrderId, ct);

        if (order == null) return new GetOrderByIdResponse(false, "Order not found.", null);
        if (order.UserId != _currentUser.Id!.Value)
            return new GetOrderByIdResponse(false, "Forbidden.", null);

        var requestPath = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestPath != null ? $"{requestPath.Scheme}://{requestPath.Host}" : "";

        var dto = new OrderDetailDto(
            order.Id, order.TotalAmount, order.Status.ToString(), order.CreatedAt,
            order.Items.Select(oi => {
                var storagePath = oi.Item.Images.FirstOrDefault(i => i.IsPrimary)?.Image?.StoragePath ?? oi.Item.Images.FirstOrDefault()?.Image?.StoragePath;
                var fullUrl = storagePath.ToAbsoluteUrl(baseUrl);
                return new OrderItemDetailDto(
                    oi.ItemId, oi.Item.TitleEn, oi.Quantity, oi.PriceAtTime,
                    fullUrl
                );
            }).ToList(),
            order.Payments.OrderByDescending(p => p.CreatedAt).FirstOrDefault()?.Status.ToString(),
            order.DeliveryTrackings.OrderByDescending(d => d.UpdatedAt).FirstOrDefault()?.Status.ToString()
        );

        return new GetOrderByIdResponse(true, null, dto);
    }
}
