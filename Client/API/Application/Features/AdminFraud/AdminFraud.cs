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

        return new GetFraudLogsResponse(logs, total, request.Page, pages);
    }
}
