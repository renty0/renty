using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;

namespace Application.Features.AdminKpis;

public record WalletTransactionDto(
    Guid Id,
    long UserId,
    decimal Amount,
    string Type,
    string Description,
    bool IsPending,
    DateTimeOffset CreatedAt
);

public record RentalFinancialBreakdownDto(
    Guid RentalId,
    decimal InitialRentalPrice,
    decimal InitialDeposit,
    decimal InitialExpertFee,
    
    decimal EscrowRental,
    decimal EscrowDeposit,
    decimal EscrowExpert,
    
    decimal DistributedToOwner,
    decimal DistributedToRenter,
    decimal DistributedToExpert,
    decimal PlatformRevenue,
    decimal PenaltiesCollected,

    string RentalStatus,
    string? CancellationReason,

    List<WalletTransactionDto> Transactions
);

public record GetRentalFinancialBreakdownQuery(Guid RentalId) : IRequest<GetRentalFinancialBreakdownResponse>;

public record GetRentalFinancialBreakdownResponse(bool Found, string? Error, RentalFinancialBreakdownDto? Breakdown);

public class GetRentalFinancialBreakdownQueryHandler : IRequestHandler<GetRentalFinancialBreakdownQuery, GetRentalFinancialBreakdownResponse>
{
    private readonly IApplicationDbContext _context;

    public GetRentalFinancialBreakdownQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetRentalFinancialBreakdownResponse> Handle(GetRentalFinancialBreakdownQuery request, CancellationToken ct)
    {
        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new GetRentalFinancialBreakdownResponse(false, "Rental not found.", null);

        var orderIdStr = rental.OrderId.ToString();
        var transactions = await _context.WalletTransactions
            .Where(t => t.RelatedRentalId == rental.Id || 
                        (t.Description != null && t.Description.Contains(orderIdStr)))
            .OrderBy(t => t.CreatedAt)
            .ToListAsync(ct);

        decimal escrowRental = 0;
        decimal escrowDeposit = 0;
        decimal escrowExpert = 0;
        
        foreach(var t in transactions.Where(t => t.IsPending))
        {
            if (t.Description != null)
            {
                if (t.Description.Contains("Rental", StringComparison.OrdinalIgnoreCase) && !t.Description.Contains("Expert", StringComparison.OrdinalIgnoreCase))
                    escrowRental += Math.Abs(t.Amount);
                if (t.Description.Contains("Deposit", StringComparison.OrdinalIgnoreCase))
                    escrowDeposit += Math.Abs(t.Amount);
                if (t.Description.Contains("Expert", StringComparison.OrdinalIgnoreCase))
                    escrowExpert += Math.Abs(t.Amount);
            }
        }

        decimal toOwner = 0;
        decimal toRenter = 0;
        decimal toExpert = 0; 
        decimal platformRevenue = 0;
        decimal penalties = 0;

        foreach(var t in transactions.Where(t => !t.IsPending))
        {
            if (t.Type == TransactionType.RentalEarnings) 
            {
                if (t.UserId == rental.Item.OwnerId) toOwner += t.Amount;
                else toExpert += t.Amount; // if Expert receives earnings
            }
            else if (t.Type == TransactionType.EscrowRelease) 
            {
                if (t.UserId == rental.UserId) toRenter += t.Amount;
                else if (t.UserId == rental.Item.OwnerId) toOwner += t.Amount;
            }
            else if (t.Type == TransactionType.Penalty)
            {
                penalties += Math.Abs(t.Amount);
            }
        }
        
        var commissionAmount = Math.Round(rental.RentalPrice * (rental.PlatformCommissionPercent / 100m), 2);
        if (rental.Status == RentalStatus.Completed)
        {
            platformRevenue = commissionAmount;
        }
        else if (rental.Status == RentalStatus.Cancelled && rental.CancellationFee > 0)
        {
            platformRevenue = Math.Round(rental.CancellationFee * (rental.PlatformCommissionPercent / 100m), 2);
        }

        var dto = new RentalFinancialBreakdownDto(
            RentalId: rental.Id,
            InitialRentalPrice: rental.RentalPrice,
            InitialDeposit: rental.DepositAmount,
            InitialExpertFee: rental.ExpertReviewFee,
            
            EscrowRental: escrowRental,
            EscrowDeposit: escrowDeposit,
            EscrowExpert: escrowExpert,
            
            DistributedToOwner: toOwner,
            DistributedToRenter: toRenter,
            DistributedToExpert: toExpert, 
            PlatformRevenue: platformRevenue,
            PenaltiesCollected: penalties,
            
            RentalStatus: rental.Status.ToString(),
            CancellationReason: null,
            
            Transactions: transactions.Select(t => new WalletTransactionDto(
                t.Id, t.UserId, t.Amount, t.Type.ToString(), t.Description ?? "", t.IsPending, t.CreatedAt
            )).ToList()
        );

        return new GetRentalFinancialBreakdownResponse(true, null, dto);
    }
}
