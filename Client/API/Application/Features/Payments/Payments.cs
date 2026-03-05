using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Payments;

// ── CREATE PAYMENT ────────────────────────────────────────────────────────────

public record CreatePaymentCommand(Guid OrderId, string Method, string? TransactionRef = null)
    : IRequest<CreatePaymentResponse>;

public record CreatePaymentResponse(bool Success, string? Error, Guid? PaymentId, string? Status, string? TransactionRef);

public class CreatePaymentCommandValidator : AbstractValidator<CreatePaymentCommand>
{
    private static readonly string[] ValidMethods = ["vodafone_cash", "fawry", "paymob", "credit_card", "bank_transfer"];

    public CreatePaymentCommandValidator()
    {
        RuleFor(x => x.OrderId).NotEmpty();
        RuleFor(x => x.Method).Must(m => ValidMethods.Contains(m.ToLower()))
            .WithMessage("Invalid payment method.");
    }
}

public class CreatePaymentCommandHandler : IRequestHandler<CreatePaymentCommand, CreatePaymentResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CreatePaymentCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreatePaymentResponse> Handle(CreatePaymentCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreatePaymentResponse(false, "Unauthorized.", null, null, null);

        var order = await _context.Orders
            .FirstOrDefaultAsync(o => o.Id == request.OrderId, ct);

        if (order == null) return new CreatePaymentResponse(false, "Order not found.", null, null, null);
        if (order.UserId != _currentUser.Id.Value)
            return new CreatePaymentResponse(false, "Forbidden.", null, null, null);
        if (order.Status != OrderStatus.Pending)
            return new CreatePaymentResponse(false, "Order is not in pending status.", null, null, null);

        // Parse method
        var methodMap = new Dictionary<string, PaymentMethod>(StringComparer.OrdinalIgnoreCase)
        {
            ["vodafone_cash"] = PaymentMethod.VodafoneCash,
            ["fawry"] = PaymentMethod.Fawry,
            ["paymob"] = PaymentMethod.Paymob,
            ["credit_card"] = PaymentMethod.CreditCard,
            ["bank_transfer"] = PaymentMethod.BankTransfer
        };

        var method = methodMap[request.Method];
        var transactionRef = request.TransactionRef ?? Guid.NewGuid().ToString("N")[..16].ToUpper();

        // Simulate payment gateway — always succeed for now
        var payment = new Payment
        {
            OrderId = request.OrderId,
            Amount = order.TotalAmount ?? 0,
            Method = method,
            Status = PaymentStatus.Success,
            TransactionRef = transactionRef,
            CreatedAt = DateTime.UtcNow
        };
        _context.Payments.Add(payment);

        // Update order status
        order.Status = OrderStatus.Paid;
        order.UpdatedAt = DateTime.UtcNow;

        // Notify buyer: "Payment Confirmed"
        _context.Notifications.Add(new Notification
        {
            UserId = order.UserId,
            Title = "Payment Confirmed",
            Message = $"Your payment of {payment.Amount:C} via {method} has been confirmed.",
            CreatedAt = DateTime.UtcNow
        });

        // Kick off delivery: insert initial tracking entry
        _context.DeliveryTrackings.Add(new DeliveryTracking
        {
            OrderId = request.OrderId,
            Status = DeliveryStatus.Processing,
            Location = null,
            UpdatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);
        return new CreatePaymentResponse(true, null, payment.Id, payment.Status.ToString(), payment.TransactionRef);
    }
}

// ── GET PAYMENT BY ORDER ──────────────────────────────────────────────────────

public record GetPaymentByOrderQuery(Guid OrderId) : IRequest<GetPaymentByOrderResponse>;
public record PaymentDto(Guid Id, decimal Amount, string Method, string Status, DateTime CreatedAt);
public record GetPaymentByOrderResponse(bool Found, string? Error, PaymentDto? Payment);

public class GetPaymentByOrderQueryHandler : IRequestHandler<GetPaymentByOrderQuery, GetPaymentByOrderResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetPaymentByOrderQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetPaymentByOrderResponse> Handle(GetPaymentByOrderQuery request, CancellationToken ct)
    {
        var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == request.OrderId, ct);
        if (order == null) return new GetPaymentByOrderResponse(false, "Order not found.", null);
        if (order.UserId != _currentUser.Id!.Value)
            return new GetPaymentByOrderResponse(false, "Forbidden.", null);

        var payment = await _context.Payments
            .Where(p => p.OrderId == request.OrderId)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new PaymentDto(p.Id, p.Amount, p.Method.ToString(), p.Status.ToString(), p.CreatedAt))
            .FirstOrDefaultAsync(ct);

        if (payment == null) return new GetPaymentByOrderResponse(false, "No payment found for this order.", null);
        return new GetPaymentByOrderResponse(true, null, payment);
    }
}
