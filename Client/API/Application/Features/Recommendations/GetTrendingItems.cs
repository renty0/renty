using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Recommendations;

public record GetTrendingItemsQuery(int Count = 10) : IRequest<List<RecommendationDto>>;

public class GetTrendingItemsQueryHandler : IRequestHandler<GetTrendingItemsQuery, List<RecommendationDto>>
{
    private readonly IApplicationDbContext _context;

    public GetTrendingItemsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<RecommendationDto>> Handle(GetTrendingItemsQuery request, CancellationToken cancellationToken)
    {
        return await _context.RentableItems
            .Include(x => x.Category)
            .Include(x => x.Images)
            .OrderByDescending(x => x.ViewCount)
            .ThenByDescending(x => x.AverageRating)
            .Take(request.Count)
            .Select(x => new RecommendationDto(
                x.Id,
                x.TitleAr,
                x.TitleEn,
                x.Images.OrderBy(i => i.DisplayOrder).Select(i => i.Image != null ? i.Image.StoragePath : null).FirstOrDefault(),
                x.PricePerDay,
                x.AverageRating,
                x.Category != null ? x.Category.NameEn : null,
                "Trending now"
            ))
            .ToListAsync(cancellationToken);
    }
}
