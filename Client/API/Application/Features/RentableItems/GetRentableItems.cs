using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentableItems;

public record GetRentableItemsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? SearchTerm = null,
    int? CategoryId = null,
    int? SubcategoryId = null,
    string? City = null,
    string? Country = null,
    decimal? MinPrice = null,
    decimal? MaxPrice = null,
    bool? IsAvailableForDelivery = null,
    long? OwnerId = null,
    ItemStatus? Status = null
) : IRequest<GetRentableItemsResponse>;

public record GetRentableItemsResponse(
    bool Success,
    string? Message,
    PaginatedList<RentableItemListDto> Items
);

public class GetRentableItemsQueryHandler : IRequestHandler<GetRentableItemsQuery, GetRentableItemsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetRentableItemsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetRentableItemsResponse> Handle(GetRentableItemsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.RentableItems
            .Include(r => r.Owner)
            .Include(r => r.Category)
            .Include(r => r.Images)
            .AsQueryable();

        // By default, show only available items unless a specific status is requested
        if (request.Status.HasValue)
        {
            query = query.Where(r => r.Status == request.Status.Value);
        }
        else if (!request.OwnerId.HasValue)
        {
            query = query.Where(r => r.Status == ItemStatus.Available);
        }

        if (request.OwnerId.HasValue)
        {
            query = query.Where(r => r.OwnerId == request.OwnerId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var searchTerm = request.SearchTerm.ToLower();
            query = query.Where(r =>
                r.Title.ToLower().Contains(searchTerm) ||
                r.Description.ToLower().Contains(searchTerm) ||
                (r.ShortDescription != null && r.ShortDescription.ToLower().Contains(searchTerm))
            );
        }

        if (request.CategoryId.HasValue)
        {
            query = query.Where(r => r.CategoryId == request.CategoryId.Value);
        }

        if (request.SubcategoryId.HasValue)
        {
            query = query.Where(r => r.SubcategoryId == request.SubcategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.City))
        {
            query = query.Where(r => r.City == request.City);
        }

        if (!string.IsNullOrWhiteSpace(request.Country))
        {
            query = query.Where(r => r.Country == request.Country);
        }

        if (request.MinPrice.HasValue)
        {
            query = query.Where(r => r.PricePerDay >= request.MinPrice.Value);
        }

        if (request.MaxPrice.HasValue)
        {
            query = query.Where(r => r.PricePerDay <= request.MaxPrice.Value);
        }

        if (request.IsAvailableForDelivery.HasValue)
        {
            query = query.Where(r => r.IsAvailableForDelivery == request.IsAvailableForDelivery.Value);
        }

        var projectedQuery = query
            .OrderByDescending(r => r.Created)
            .Select(r => new RentableItemListDto(
                r.Id,
                r.Title,
                r.ShortDescription,
                r.PricePerDay,
                r.City,
                r.Country,
                r.Status.ToString(),
                r.AverageRating,
                r.TotalRatings,
                r.Images.Where(i => i.IsPrimary).Select(i => i.ImageUrl).FirstOrDefault()
                    ?? r.Images.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).FirstOrDefault(),
                r.Owner.FirstName + " " + r.Owner.LastName,
                r.Category != null ? r.Category.CategoryName : null
            ));

        var items = await PaginatedList<RentableItemListDto>.CreateAsync(
            projectedQuery,
            request.PageNumber,
            request.PageSize,
            cancellationToken
        );

        return new GetRentableItemsResponse(true, null, items);
    }
}
