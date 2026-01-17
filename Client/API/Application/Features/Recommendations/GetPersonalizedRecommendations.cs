using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Recommendations;

public record GetPersonalizedRecommendationsQuery(int Count = 10) : IRequest<List<RecommendationDto>>;

public class GetPersonalizedRecommendationsQueryHandler : IRequestHandler<GetPersonalizedRecommendationsQuery, List<RecommendationDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetPersonalizedRecommendationsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<List<RecommendationDto>> Handle(GetPersonalizedRecommendationsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUser.Id;
        if (userId == null)
        {
            // If not logged in, return trending
            return await _context.RentableItems
                .Include(x => x.Category)
                .Include(x => x.Images)
                .OrderByDescending(x => x.ViewCount)
                .Take(request.Count)
                .Select(x => new RecommendationDto(
                    x.Id,
                    x.Title,
                    x.Images.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).FirstOrDefault(),
                    x.PricePerDay,
                    x.AverageRating,
                    x.Category != null ? x.Category.CategoryName : null,
                    "Popular in Rently"
                ))
                .ToListAsync(cancellationToken);
        }

        // Simple personalized logic: Find categories user has rented from, suggest more from those
        var rentedCategories = await _context.RentRequests
            .Where(x => x.RenterId == userId.Value)
            .Select(x => x.RentableItem.CategoryId)
            .Distinct()
            .ToListAsync(cancellationToken);

        if (!rentedCategories.Any())
        {
            return await _context.RentableItems
                .Include(x => x.Category)
                .Include(x => x.Images)
                .OrderByDescending(x => x.ViewCount)
                .Take(request.Count)
                .Select(x => new RecommendationDto(
                    x.Id,
                    x.Title,
                    x.Images.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).FirstOrDefault(),
                    x.PricePerDay,
                    x.AverageRating,
                    x.Category != null ? x.Category.CategoryName : null,
                    "Highly rated"
                ))
                .ToListAsync(cancellationToken);
        }

        return await _context.RentableItems
            .Include(x => x.Category)
            .Include(x => x.Images)
            .Where(x => x.CategoryId != null && rentedCategories.Contains(x.CategoryId))
            .OrderByDescending(x => x.AverageRating)
            .Take(request.Count)
            .Select(x => new RecommendationDto(
                x.Id,
                x.Title,
                x.Images.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).FirstOrDefault(),
                x.PricePerDay,
                x.AverageRating,
                x.Category != null ? x.Category.CategoryName : null,
                "Based on your interest"
            ))
            .ToListAsync(cancellationToken);
    }
}
