using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;


namespace Application.Features.Items;

public record GetItemByIdQuery(Guid ItemId) : IRequest<GetItemByIdResponse>;

public record GetItemByIdResponse(bool Found, string? Error, ItemDetailDto? Item);

public class GetItemByIdQueryHandler : IRequestHandler<GetItemByIdQuery, GetItemByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetItemByIdQueryHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetItemByIdResponse> Handle(GetItemByIdQuery request, CancellationToken ct)
    {
        var item = await _context.Items
            .Include(i => i.Owner)
            .Include(i => i.Pricing)
            .Include(i => i.Images)
                .ThenInclude(img => img.Image)
            .Include(i => i.Category)
            .Include(i => i.Subcategory)
            .Include(i => i.Brand)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null)
            return new GetItemByIdResponse(false, "Item not found.", null);

        if (_currentUser.Id.HasValue)
        {
            _context.UserInteractions.Add(new Domain.Entities.UserInteraction
            {
                UserId = _currentUser.Id.Value,
                ItemId = item.Id,
                Action = InteractionAction.View,
                CreatedAt = DateTime.UtcNow
            });
            await _context.SaveChangesAsync(ct);
        }

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : null;

        var dto = new ItemDetailDto(
            item.Id,
            item.TitleAr,
            item.TitleEn,
            item.DescAr,
            item.DescEn,
            item.Type.ToString(),
            item.Status.ToString(),
            item.Condition,
            item.DefaultDeposit,
            item.Location,
            item.City,
            item.Lat,
            item.Lng,
            item.IsForSale,
            item.SalePrice,
            item.CreatedAt,
            new OwnerDto(
                item.OwnerId,
                item.Owner.FirstName, 
                item.Owner.LastName,
                item.Owner.City, 
                !string.IsNullOrEmpty(item.Owner.ProfilePictureUrl) && !string.IsNullOrEmpty(baseUrl) 
                    ? $"{baseUrl.TrimEnd('/')}/{item.Owner.ProfilePictureUrl.TrimStart('/')}" 
                    : item.Owner.ProfilePictureUrl,
                item.Owner.Rating,
                item.Owner.TotalRatings),
            item.Pricing.Select(p => new ItemPricingDto(p.PricingType, p.Price)).ToList(),
            item.Images.Select(img => new ItemImageDto(
                img.ImageId, 
                img.Image != null 
                    ? (!string.IsNullOrEmpty(baseUrl) ? $"{baseUrl.TrimEnd('/')}/{img.Image.StoragePath.TrimStart('/')}" : "/" + img.Image.StoragePath.Replace("\\", "/").TrimStart('/'))
                    : "", 
                img.IsPrimary)).ToList(),
            await _context.Reviews.Where(r => r.Rental.ItemId == item.Id).AverageAsync(r => (double?)r.Rating, ct) ?? 0, 
            await _context.Reviews.CountAsync(r => r.Rental.ItemId == item.Id, ct), 
            item.Category    != null ? new ItemCategoryRef(item.Category.Id, item.Category.NameAr, item.Category.NameEn) : null,
            item.Subcategory != null ? new ItemSubcategoryRef(item.Subcategory.Id, item.Subcategory.NameAr, item.Subcategory.NameEn) : null,
            item.Brand       != null ? new ItemBrandRef(item.Brand.Id, item.Brand.NameAr, item.Brand.NameEn) : null
        );

        return new GetItemByIdResponse(true, null, dto);
    }
}
