using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Recommendations;

public record GetSimilarItemsQuery(long ItemId, int Count = 5) : IRequest<List<RecommendationDto>>;

public class GetSimilarItemsQueryHandler : IRequestHandler<GetSimilarItemsQuery, List<RecommendationDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSimilarItemsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<RecommendationDto>> Handle(GetSimilarItemsQuery request, CancellationToken cancellationToken)
    {
        var item = await _context.RentableItems.FindAsync(new object[] { request.ItemId }, cancellationToken);
        if (item == null) return new List<RecommendationDto>();

        return await _context.RentableItems
            .Include(x => x.Category)
            .Include(x => x.Images)
            .Where(x => x.Id != request.ItemId && x.CategoryId == item.CategoryId)
            .OrderByDescending(x => x.AverageRating)
            .Take(request.Count)
            .Select(x => new RecommendationDto(
                x.Id,
                x.TitleAr,
                x.TitleEn,
                x.Images.OrderBy(i => i.DisplayOrder).Select(i => i.Image != null ? i.Image.StoragePath : null).FirstOrDefault(),
                x.PricePerDay,
                x.AverageRating,
                x.Category != null ? x.Category.NameEn : null,
                "Similar to this item"
            ))
            .ToListAsync(cancellationToken);
    }
}
