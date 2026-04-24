using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.AdminFraud;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record FraudUserDto(long Id, string FirstName, string Email);
public record FraudLogDto(
    Guid Id,
    FraudUserDto User,
    double RiskScore,
    string Decision,
    string? Reason,
    string? FraudIndicators,
    DateTime CreatedAt
);

// ── GET FRAUD LOGS ────────────────────────────────────────────────────────────

public record GetFraudLogsQuery(
    string? Decision = null,
    double? MinRisk = null,
    int Page = 1,
    int Limit = 20
) : IRequest<GetFraudLogsResponse>;

public record GetFraudLogsResponse(List<FraudLogDto> Logs, int Total, int Page, int Pages);

public class GetFraudLogsQueryHandler : IRequestHandler<GetFraudLogsQuery, GetFraudLogsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetFraudLogsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetFraudLogsResponse> Handle(GetFraudLogsQuery request, CancellationToken ct)
    {
        var query = _context.FraudLogs
            .Include(f => f.User)
            .AsQueryable();

        if (!string.IsNullOrEmpty(request.Decision))
            query = query.Where(f => f.Decision == request.Decision.ToLower());

        if (request.MinRisk.HasValue)
            query = query.Where(f => f.RiskScore >= request.MinRisk.Value);

        var total = await query.CountAsync(ct);
        var pages = (int)Math.Ceiling((double)total / request.Limit);

        var logs = await query
            .OrderByDescending(f => f.CreatedAt)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(f => new FraudLogDto(
                f.Id,
                new FraudUserDto(f.User.Id, f.User.FirstName, f.User.Email!),
                f.RiskScore,
                f.Decision,
                f.Reason,
                f.FraudIndicators,
                f.CreatedAt
            ))
            .ToListAsync(ct);

        // ── LIVE RISK ANALYSIS (Inject real-time alerts if page 1) ────────────────
        if (request.Page == 1 && string.IsNullOrEmpty(request.Decision))
        {
            // 1. Find Unverified Users with High-Value Pending Orders
            var highValueRisks = await _context.Orders
                .Include(o => o.User)
                .Where(o => !o.User.IdVerified && (o.TotalAmount ?? 0) > 2000)
                .OrderByDescending(o => o.CreatedAt)
                .Take(3)
                .Select(o => new FraudLogDto(
                    Guid.Empty,
                    new FraudUserDto(o.User.Id, o.User.FirstName, o.User.Email!),
                    0.82,
                    "Manual Review",
                    "High-value order from unverified identity",
                    "LIVE_RISK: Unverified_HighValue",
                    o.CreatedAt
                ))
                .ToListAsync(ct);

            // 2. High Velocity Check (Users with 3+ orders in last 24h)
            var yesterday = DateTime.UtcNow.AddDays(-1);
            var velocityRisks = await _context.Orders
                .Include(o => o.User)
                .Where(o => o.CreatedAt > yesterday)
                .GroupBy(o => o.UserId)
                .Where(g => g.Count() >= 3)
                .Select(g => new { UserId = g.Key, Count = g.Count(), Latest = g.Max(x => x.CreatedAt) })
                .Join(_context.Users, g => g.UserId, u => u.Id, (g, u) => new FraudLogDto(
                    Guid.Empty,
                    new FraudUserDto(u.Id, u.FirstName, u.Email!),
                    0.65,
                    "Alert",
                    $"Account placed {g.Count} orders in 24h",
                    "LIVE_RISK: High_Velocity",
                    g.Latest
                ))
                .Take(3)
                .ToListAsync(ct);

            logs.InsertRange(0, highValueRisks);
            logs.InsertRange(0, velocityRisks);
        }

        return new GetFraudLogsResponse(logs, total, request.Page, pages);
    }
}
