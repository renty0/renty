using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.ItemRecommendations;

// ── DTOs ─────────────────────────────────────────────────────────────────────
public record RecommendationItemDto(Guid Id, string Title, decimal? Price, string? Image, string? City);
public record RecommendationEntryDto(Guid Id, RecommendationItemDto Item, double Score, string? Reason, string? Algorithm);

// ── GET RECOMMENDATIONS ───────────────────────────────────────────────────────

public record GetRecommendationsQuery : IRequest<GetRecommendationsResponse>;
public record GetRecommendationsResponse(List<RecommendationEntryDto> Recommendations);

public class GetRecommendationsQueryHandler : IRequestHandler<GetRecommendationsQuery, GetRecommendationsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetRecommendationsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetRecommendationsResponse> Handle(GetRecommendationsQuery request, CancellationToken ct)
    {
        var recs = await _context.ItemRecommendations
            .Include(r => r.Item).ThenInclude(i => i.Images)
            .Include(r => r.Item).ThenInclude(i => i.Pricing)
            .Where(r => r.UserId == _currentUser.Id!.Value)
            .OrderByDescending(r => r.Score)
            .Select(r => new RecommendationEntryDto(
                r.Id,
                new RecommendationItemDto(
                    r.Item.Id,
                    r.Item.Title,
                    r.Item.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                    r.Item.Images.Where(i => i.IsPrimary).Select(i => i.ImageUrl).FirstOrDefault()
                        ?? r.Item.Images.Select(i => i.ImageUrl).FirstOrDefault(),
                    r.Item.City
                ),
                r.Score, r.Reason, r.Algorithm
            ))
            .ToListAsync(ct);

        return new GetRecommendationsResponse(recs);
    }
}

// ── RECORD CLICK ─────────────────────────────────────────────────────────────

public record RecordRecommendationClickCommand(Guid RecommendationId) : IRequest<RecordClickResponse>;
public record RecordClickResponse(bool Success, string? Error);

public class RecordRecommendationClickCommandHandler : IRequestHandler<RecordRecommendationClickCommand, RecordClickResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public RecordRecommendationClickCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RecordClickResponse> Handle(RecordRecommendationClickCommand request, CancellationToken ct)
    {
        var rec = await _context.ItemRecommendations
            .FirstOrDefaultAsync(r => r.Id == request.RecommendationId && r.UserId == _currentUser.Id!.Value, ct);

        if (rec == null) return new RecordClickResponse(false, "Recommendation not found.");

        rec.IsClicked = true;

        _context.UserInteractions.Add(new Domain.Entities.UserInteraction
        {
            UserId = _currentUser.Id!.Value,
            ItemId = rec.ItemId,
            Action = InteractionAction.Click,
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);
        return new RecordClickResponse(true, null);
    }
}
