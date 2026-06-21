using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Configuration;

namespace Application.Features.ItemRecommendations;

public record RecommendationItemDto(Guid Id, string Title, decimal? Price, string? Image, string? City);
public record RecommendationEntryDto(Guid Id, RecommendationItemDto Item, double Score, string? Reason, string? Algorithm);

public record PythonResponse(
    [property: JsonPropertyName("recommendations")] List<string> Recommendations,
    [property: JsonPropertyName("algorithm")] string Algorithm
);

public record GetRecommendationsQuery : IRequest<GetRecommendationsResponse>;
public record GetRecommendationsResponse(List<RecommendationEntryDto> Recommendations);

public class GetRecommendationsQueryHandler : IRequestHandler<GetRecommendationsQuery, GetRecommendationsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetRecommendationsQueryHandler(
        IApplicationDbContext context,
        IUser currentUser,
        HttpClient httpClient,
        IConfiguration configuration,
        IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpClient = httpClient;
        _configuration = configuration;
        _httpContextAccessor = httpContextAccessor;
    }

    private string BuildImageUrl(string? storagePath)
    {
        if (string.IsNullOrEmpty(storagePath)) return string.Empty;
        if (storagePath.StartsWith("http")) return storagePath;
        var req = _httpContextAccessor.HttpContext?.Request;
        if (req != null)
        {
            var baseUrl = $"{req.Scheme}://{req.Host}";
            return $"{baseUrl}/{storagePath.Replace("\\", "/").TrimStart('/')}";
        }
        return storagePath;
    }

    public async Task<GetRecommendationsResponse> Handle(GetRecommendationsQuery request, CancellationToken ct)
    {
        var userId = _currentUser.Id;
        if (userId == null)
        {
            var trendingItems = await GetTrendingFallback(ct);
            return new GetRecommendationsResponse(trendingItems);
        }

        var apiUrl = _configuration["RecommendationSettings:ApiUrl"] ?? "http://localhost:8000";
        List<string>? recommendedGuids = null;
        string algorithm = "Collaborative Filtering (DB)";

        try
        {
            var response = await _httpClient.GetFromJsonAsync<PythonResponse>(
                $"{apiUrl.TrimEnd('/')}/recommend?user_id={userId.Value}&count=4", 
                ct);

            if (response != null && response.Recommendations != null && response.Recommendations.Any())
            {
                recommendedGuids = response.Recommendations;
                algorithm = response.Algorithm;
            }
        }
        catch (Exception ex)
        {
            System.Console.WriteLine($"Recommendation API call failed: {ex.Message}");
        }

        List<RecommendationEntryDto> finalRecs = new();

        if (recommendedGuids != null && recommendedGuids.Any())
        {
            var itemGuids = recommendedGuids
                .Select(id => Guid.TryParse(id, out var g) ? g : Guid.Empty)
                .Where(g => g != Guid.Empty)
                .ToList();

            var items = await _context.Items
                .Include(i => i.Images).ThenInclude(img => img.Image)
                .Include(i => i.Pricing)
                .Where(i => itemGuids.Contains(i.Id))
                .ToListAsync(ct);

            var orderedItems = itemGuids
                .Select(id => items.FirstOrDefault(i => i.Id == id))
                .Where(i => i != null)
                .ToList();

            double score = 1.0;
            foreach (var item in orderedItems)
            {
                if (item == null) continue;
                finalRecs.Add(new RecommendationEntryDto(
                    Guid.NewGuid(),
                    new RecommendationItemDto(
                        item.Id,
                        item.TitleEn,
                        item.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                        BuildImageUrl(
                            item.Images.Where(i => i.IsPrimary && i.Image != null).Select(i => i.Image!.StoragePath).FirstOrDefault()
                            ?? item.Images.Where(i => i.Image != null).Select(i => i.Image!.StoragePath).FirstOrDefault()),
                        item.City
                    ),
                    score,
                    "Recommended for you",
                    algorithm
                ));
                score -= 0.1;
            }
        }

        if (!finalRecs.Any())
        {
            finalRecs = await GetCategoryOrTrendingFallback(userId.Value, ct);
        }

        return new GetRecommendationsResponse(finalRecs);
    }

    private async Task<List<RecommendationEntryDto>> GetTrendingFallback(CancellationToken ct)
    {
        var items = await _context.Items
            .Include(i => i.Images).ThenInclude(img => img.Image)
            .Include(i => i.Pricing)
            .Where(i => i.Status == NewItemStatus.Available || i.Status == NewItemStatus.Rented)
            .OrderByDescending(i => i.Interactions.Count(ui => ui.Action == InteractionAction.View))
            .Take(4)
            .ToListAsync(ct);

        return items.Select((item, idx) => new RecommendationEntryDto(
            Guid.NewGuid(),
            new RecommendationItemDto(
                item.Id,
                item.TitleEn,
                item.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                BuildImageUrl(
                    item.Images.Where(i => i.IsPrimary && i.Image != null).Select(i => i.Image!.StoragePath).FirstOrDefault()
                    ?? item.Images.Where(i => i.Image != null).Select(i => i.Image!.StoragePath).FirstOrDefault()),
                item.City
            ),
            1.0 - (idx * 0.1),
            "Popular in Rently",
            "Trending (Fallback)"
        )).ToList();
    }

    private async Task<List<RecommendationEntryDto>> GetCategoryOrTrendingFallback(long userId, CancellationToken ct)
    {
        var interestedCategories = await _context.UserInteractions
            .Where(ui => ui.UserId == userId && ui.ItemId != null)
            .Select(ui => ui.Item!.CategoryId)
            .Where(cId => cId != null)
            .Distinct()
            .Take(3)
            .ToListAsync(ct);

        if (!interestedCategories.Any())
        {
            interestedCategories = await _context.RentRequests
                .Where(r => r.RenterId == userId)
                .Select(r => r.RentableItem.CategoryId)
                .Where(cId => cId != null)
                .Distinct()
                .Take(3)
                .ToListAsync(ct);
        }

        if (interestedCategories.Any())
        {
            var items = await _context.Items
                .Include(i => i.Images).ThenInclude(img => img.Image)
                .Include(i => i.Pricing)
                .Where(i => i.CategoryId != null && interestedCategories.Contains(i.CategoryId))
                .Where(i => i.Status == NewItemStatus.Available || i.Status == NewItemStatus.Rented)
                .OrderByDescending(i => i.Interactions.Count(ui => ui.Action == InteractionAction.View))
                .Take(4)
                .ToListAsync(ct);

            if (items.Any())
            {
                return items.Select((item, idx) => new RecommendationEntryDto(
                    Guid.NewGuid(),
                    new RecommendationItemDto(
                        item.Id,
                        item.TitleEn,
                        item.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                        BuildImageUrl(
                            item.Images.Where(i => i.IsPrimary && i.Image != null).Select(i => i.Image!.StoragePath).FirstOrDefault()
                            ?? item.Images.Where(i => i.Image != null).Select(i => i.Image!.StoragePath).FirstOrDefault()),
                        item.City
                    ),
                    1.0 - (idx * 0.1),
                    "Based on your category interest",
                    "Category-Interest (Fallback)"
                )).ToList();
            }
        }

        return await GetTrendingFallback(ct);
    }
}


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
