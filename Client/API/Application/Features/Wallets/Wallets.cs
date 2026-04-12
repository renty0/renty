using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Wallets;

// ── GET WALLET BALANCE ────────────────────────────────────────────────────────

public record GetWalletBalanceQuery : IRequest<GetWalletBalanceResponse>;
public record GetWalletBalanceResponse(bool Success, string? Error, decimal Balance);

public class GetWalletBalanceQueryHandler : IRequestHandler<GetWalletBalanceQuery, GetWalletBalanceResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetWalletBalanceQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetWalletBalanceResponse> Handle(GetWalletBalanceQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new GetWalletBalanceResponse(false, "Unauthorized", 0);

        var user = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);

        if (user == null) return new GetWalletBalanceResponse(false, "User not found", 0);

        return new GetWalletBalanceResponse(true, null, user.WalletBalance);
    }
}

// ── GET WALLET TRANSACTIONS ──────────────────────────────────────────────────

public record WalletTransactionDto(Guid Id, decimal Amount, string Type, string Description, DateTimeOffset CreatedAt);

public record GetWalletTransactionsQuery : IRequest<GetWalletTransactionsResponse>;
public record GetWalletTransactionsResponse(bool Success, string? Error, List<WalletTransactionDto>? Transactions);

public class GetWalletTransactionsQueryHandler : IRequestHandler<GetWalletTransactionsQuery, GetWalletTransactionsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetWalletTransactionsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetWalletTransactionsResponse> Handle(GetWalletTransactionsQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new GetWalletTransactionsResponse(false, "Unauthorized", null);

        var transactions = await _context.WalletTransactions
            .AsNoTracking()
            .Where(t => t.UserId == _currentUser.Id.Value)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new WalletTransactionDto(
                t.Id,
                t.Amount,
                t.Type.ToString(),
                t.Description,
                t.CreatedAt
            ))
            .ToListAsync(ct);

        return new GetWalletTransactionsResponse(true, null, transactions);
    }
}

// ── REQUEST WITHDRAWAL ────────────────────────────────────────────────────────

public record RequestWithdrawalCommand(decimal Amount, string MobileWalletNumber) : IRequest<RequestWithdrawalResponse>;
public record RequestWithdrawalResponse(bool Success, string? Error);

public class RequestWithdrawalCommandValidator : AbstractValidator<RequestWithdrawalCommand>
{
    public RequestWithdrawalCommandValidator()
    {
        RuleFor(x => x.Amount).GreaterThan(0).WithMessage("Amount must be greater than zero.");
        RuleFor(x => x.MobileWalletNumber).NotEmpty().WithMessage("Mobile wallet number is required.");
    }
}

public class RequestWithdrawalCommandHandler : IRequestHandler<RequestWithdrawalCommand, RequestWithdrawalResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public RequestWithdrawalCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RequestWithdrawalResponse> Handle(RequestWithdrawalCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new RequestWithdrawalResponse(false, "Unauthorized");

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);

        if (user == null) return new RequestWithdrawalResponse(false, "User not found");

        if (user.WalletBalance < request.Amount)
        {
            return new RequestWithdrawalResponse(false, "Insufficient wallet balance.");
        }

        // Deduct from balance
        user.WalletBalance -= request.Amount;

        // Record the transaction
        var transaction = new WalletTransaction
        {
            UserId = user.Id,
            Amount = -request.Amount, // Negative since it's a deduction
            Type = TransactionType.Withdrawal,
            Description = $"Withdrawal requested to {request.MobileWalletNumber}",
            ReferenceId = request.MobileWalletNumber,
            CreatedAt = DateTimeOffset.UtcNow
        };

        _context.WalletTransactions.Add(transaction);
        await _context.SaveChangesAsync(ct);

        return new RequestWithdrawalResponse(true, null);
    }
}
