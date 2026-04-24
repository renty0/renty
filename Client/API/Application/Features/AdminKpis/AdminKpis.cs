using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.AdminKpis;

// ── DTOs ─────────────────────────────────────────────────────────────────────
public record KpiSnapshotDto(
    Guid Id, DateTime Date, string Period,
    int ActiveUsers, int NewUsers, int Rentals,
    decimal Revenue, double FraudRate, double RecommendationCtr,
    int TotalItems, int TotalOrders, DateTime CreatedAt
);

// ── GET KPI SNAPSHOTS ─────────────────────────────────────────────────────────

public record GetKpisQuery(
    string? Period = null,
    DateTime? From = null,
    DateTime? To = null
) : IRequest<GetKpisResponse>;

public record GetKpisResponse(List<KpiSnapshotDto> Snapshots);

public class GetKpisQueryHandler : IRequestHandler<GetKpisQuery, GetKpisResponse>
{
    private readonly IApplicationDbContext _context;

    public GetKpisQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetKpisResponse> Handle(GetKpisQuery request, CancellationToken ct)
    {
        var snapshots = await _context.KpiSnapshots
            .Where(k => (string.IsNullOrEmpty(request.Period) || k.Period == request.Period.ToLower()) &&
                        (!request.From.HasValue || k.Date >= request.From.Value) &&
                        (!request.To.HasValue || k.Date <= request.To.Value))
            .OrderByDescending(k => k.Date)
            .Select(k => new KpiSnapshotDto(
                k.Id, k.Date, k.Period,
                k.ActiveUsers, k.NewUsers, k.Rentals,
                k.Revenue, k.FraudRate, k.RecommendationCtr,
                k.TotalItems, k.TotalOrders, k.CreatedAt
            ))
            .ToListAsync(ct);

        // If no snapshots found, generate a "Live" one for today
        if (!snapshots.Any() && (!request.From.HasValue || request.From.Value <= DateTime.Today))
        {
            var liveSnapshot = await GetLiveKpiAsync(ct);
            snapshots.Insert(0, liveSnapshot);
        }

        return new GetKpisResponse(snapshots);
    }

    private async Task<KpiSnapshotDto> GetLiveKpiAsync(CancellationToken ct)
    {
        var totalUsers = await _context.Users.CountAsync(ct);
        var totalItems = await _context.Items.CountAsync(ct);
        var orders = await _context.Orders.ToListAsync(ct);
        
        var revenue = orders.Sum(o => o.TotalAmount ?? 0);
        var fraudRate = 0.0; // Could be calculated from FraudLogs

        return new KpiSnapshotDto(
            Guid.Empty, DateTime.Today, "daily",
            totalUsers, 0, orders.Count,
            revenue, fraudRate, 0.15,
            totalItems, orders.Count, DateTime.UtcNow
        );
    }
}

// ── GET LATEST KPI ────────────────────────────────────────────────────────────

public record GetLatestKpiQuery : IRequest<GetLatestKpiResponse>;
public record GetLatestKpiResponse(bool Found, KpiSnapshotDto? Snapshot);

public class GetLatestKpiQueryHandler : IRequestHandler<GetLatestKpiQuery, GetLatestKpiResponse>
{
    private readonly IApplicationDbContext _context;

    public GetLatestKpiQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetLatestKpiResponse> Handle(GetLatestKpiQuery request, CancellationToken ct)
    {
        var snapshot = await _context.KpiSnapshots
            .OrderByDescending(k => k.Date)
            .Select(k => new KpiSnapshotDto(
                k.Id, k.Date, k.Period,
                k.ActiveUsers, k.NewUsers, k.Rentals,
                k.Revenue, k.FraudRate, k.RecommendationCtr,
                k.TotalItems, k.TotalOrders, k.CreatedAt
            ))
            .FirstOrDefaultAsync(ct);

        if (snapshot == null) 
        {
            // Calculate live if not found
            var totalUsers = await _context.Users.CountAsync(ct);
            var totalItems = await _context.Items.CountAsync(ct);
            var ordersCount = await _context.Orders.CountAsync(ct);
            var revenue = await _context.Orders.SumAsync(o => o.TotalAmount ?? 0, ct);

            snapshot = new KpiSnapshotDto(
                Guid.Empty, DateTime.Today, "live",
                totalUsers, 0, ordersCount,
                revenue, 0, 0,
                totalItems, ordersCount, DateTime.UtcNow
            );
        }
        
        return new GetLatestKpiResponse(true, snapshot);
    }
}

// ── GET GAP ANALYSIS ──────────────────────────────────────────────────────────

public record GetGapAnalysisQuery(string? Period = null, int Limit = 20) : IRequest<GetGapAnalysisResponse>;

public record GapDto(
    string CategoryName, int Demand, int Supply,
    double GapScore, string? Recommendations, DateTime CreatedAt
);

public record GetGapAnalysisResponse(List<GapDto> Gaps);

public class GetGapAnalysisQueryHandler : IRequestHandler<GetGapAnalysisQuery, GetGapAnalysisResponse>
{
    private readonly IApplicationDbContext _context;

    public GetGapAnalysisQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetGapAnalysisResponse> Handle(GetGapAnalysisQuery request, CancellationToken ct)
    {
        // 1. Try to get latest batch results (but filter out old mock data)
        var latestBatchId = await _context.GapAnalysisResults
            .Where(g => g.CreatedAt > DateTime.UtcNow.AddDays(-30)) // Ignore very old results
            .OrderByDescending(g => g.CreatedAt)
            .Select(g => g.BatchId)
            .FirstOrDefaultAsync(ct);

        if (latestBatchId != Guid.Empty)
        {
            var gaps = await _context.GapAnalysisResults
                .Where(g => g.BatchId == latestBatchId)
                .OrderByDescending(g => g.GapScore)
                .Take(request.Limit)
                .Select(g => new GapDto(
                    g.Category,
                    g.Demand,
                    g.Supply,
                    g.GapScore,
                    null,
                    g.CreatedAt
                ))
                .ToListAsync(ct);

            if (gaps.Any()) return new GetGapAnalysisResponse(gaps);
        }

        // 2. If no fresh batch results, calculate LIVE from Items & OrderItems
        var categories = await _context.ProductCategories.ToListAsync(ct);
        var items = await _context.Items.ToListAsync(ct);
        var orderItems = await _context.OrderItems.Include(oi => oi.Item).ToListAsync(ct);

        var liveGaps = categories.Select(c => {
            var supply = items.Count(i => i.CategoryId == c.Id);
            var demand = orderItems.Where(oi => oi.Item?.CategoryId == c.Id).Sum(oi => oi.Quantity);
            var score = (double)(demand + 1) / (supply + 1);
            
            return new GapDto(
                c.NameEn ?? c.NameAr,
                demand,
                supply,
                Math.Round(score, 2),
                null,
                DateTime.UtcNow
            );
        })
        .OrderByDescending(g => g.GapScore)
        .Take(request.Limit)
        .ToList();

        return new GetGapAnalysisResponse(liveGaps);
    }
}
