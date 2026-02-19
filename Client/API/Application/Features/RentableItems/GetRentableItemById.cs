using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentableItems;

public record GetRentableItemByIdQuery(long Id) : IRequest<GetRentableItemByIdResponse>;

public record GetRentableItemByIdResponse(
    bool Success,
    string? Message,
    RentableItemDto? Item
);

public class GetRentableItemByIdQueryHandler : IRequestHandler<GetRentableItemByIdQuery, GetRentableItemByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetRentableItemByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetRentableItemByIdResponse> Handle(GetRentableItemByIdQuery request, CancellationToken cancellationToken)
    {
        var item = await _context.RentableItems
            .Include(r => r.Owner)
            .Include(r => r.Category)
            .Include(r => r.Subcategory)
            .Include(r => r.Images)
            .Where(r => r.Id == request.Id)
            .Select(r => new RentableItemDto(
                r.Id,
                r.Title,
                r.Description,
                r.ShortDescription,
                r.PricePerDay,
                r.PricePerWeek,
                r.PricePerMonth,
                r.SecurityDeposit,
                r.Location,
                r.City,
                r.Country,
                r.Latitude,
                r.Longitude,
                r.Status.ToString(),
                r.MinRentalDays,
                r.MaxRentalDays,
                r.IsAvailableForDelivery,
                r.DeliveryFee,
                r.Terms,
                r.CancellationPolicy,
                r.ViewCount,
                r.AverageRating,
                r.TotalRatings,
                r.OwnerId,
                r.Owner.FirstName + " " + r.Owner.LastName,
                r.CategoryId,
                r.Category != null ? r.Category.NameEn : null,
                r.SubcategoryId,
                r.Subcategory != null ? r.Subcategory.NameEn : null,
                r.Images.OrderBy(i => i.DisplayOrder).Select(i => new RentableItemImageDto(
                    i.Id,
                    i.ImageUrl,
                    i.ThumbnailUrl,
                    i.AltText,
                    i.DisplayOrder,
                    i.IsPrimary
                )).ToList(),
                r.Created
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (item == null)
        {
            return new GetRentableItemByIdResponse(false, "Item not found.", null);
        }

        // Increment view count
        var entity = await _context.RentableItems.FindAsync(new object[] { request.Id }, cancellationToken);
        if (entity != null)
        {
            entity.ViewCount++;
            await _context.SaveChangesAsync(cancellationToken);
        }

        return new GetRentableItemByIdResponse(true, null, item);
    }
}
