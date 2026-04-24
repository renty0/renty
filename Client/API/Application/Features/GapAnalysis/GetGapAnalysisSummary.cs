using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.GapAnalysis;

public record GetGapAnalysisSummaryQuery : IRequest<GapAnalysisSummaryDto>;

public class GetGapAnalysisSummaryQueryHandler : IRequestHandler<GetGapAnalysisSummaryQuery, GapAnalysisSummaryDto>
{
    private readonly IApplicationDbContext _context;

    public GetGapAnalysisSummaryQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GapAnalysisSummaryDto> Handle(GetGapAnalysisSummaryQuery request, CancellationToken cancellationToken)
    {
        var latestBatch = await _context.GapAnalysisResults
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => r.BatchId)
            .FirstOrDefaultAsync(cancellationToken);

        if (latestBatch == Guid.Empty)
        {
            return new GapAnalysisSummaryDto(0, 0, 0, 0, "", 0, 0, 0, new List<CategoryGapScoreDto>());
        }

        var results = await _context.GapAnalysisResults
            .Where(r => r.BatchId == latestBatch)
            .ToListAsync(cancellationToken);

        var totalCategories = results.Count;
        var criticalGaps = results.Where(r => r.GapStatus == "Critical Gap" || r.GapStatus == "High Gap").ToList();

        var criticalCount = results.Count(r => r.GapStatus == "Critical Gap" || r.GapStatus == "High Gap");
        
        var mostSevere = results.OrderByDescending(r => r.GapScore).FirstOrDefault();
        
        var categoryGapsList = results.Select(r => new CategoryGapScoreDto(
            r.Category,
            (decimal)r.GapScore,
            r.GapStatus,
            r.Supply,
            r.Demand
        )).ToList();

        return new GapAnalysisSummaryDto(
            totalCategories,
            criticalCount,
            totalCategories > 0 ? Math.Round((decimal)criticalCount / totalCategories * 100, 2) : 0,
            results.Any() ? Math.Round((decimal)results.Average(r => r.GapScore), 2) : 0,
            mostSevere?.Category ?? "",
            mostSevere != null ? (decimal)mostSevere.GapScore : 0,
            results.Sum(r => r.Supply),
            results.Sum(r => r.Demand),
            categoryGapsList
        );
    }
}
