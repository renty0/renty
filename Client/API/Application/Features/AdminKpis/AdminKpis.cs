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
        var query = _context.KpiSnapshots.AsQueryable();

        if (!string.IsNullOrEmpty(request.Period))
            query = query.Where(k => k.Period == request.Period.ToLower());

        if (request.From.HasValue)
            query = query.Where(k => k.Date >= request.From.Value);

        if (request.To.HasValue)
            query = query.Where(k => k.Date <= request.To.Value);

        var snapshots = await query
            .OrderByDescending(k => k.Date)
            .Select(k => new KpiSnapshotDto(
                k.Id, k.Date, k.Period,
                k.ActiveUsers, k.NewUsers, k.Rentals,
                k.Revenue, k.FraudRate, k.RecommendationCtr,
                k.TotalItems, k.TotalOrders, k.CreatedAt
            ))
            .ToListAsync(ct);

        return new GetKpisResponse(snapshots);
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

        if (snapshot == null) return new GetLatestKpiResponse(false, null);
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
        var gaps = await _context.GapAnalysisResults
            .OrderByDescending(g => g.GapScore)
            .Take(request.Limit)
            .Select(g => new GapDto(
                g.Category,
                g.Demand,
                g.Supply,
                g.GapScore,
                null, // Recommendations field — not in existing entity, extendable
                g.CreatedAt
            ))
            .ToListAsync(ct);

        return new GetGapAnalysisResponse(gaps);
    }
}
