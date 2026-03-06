using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Items;

public record GetItemByIdQuery(Guid ItemId) : IRequest<GetItemByIdResponse>;

public record GetItemByIdResponse(bool Found, string? Error, ItemDetailDto? Item);

public class GetItemByIdQueryHandler : IRequestHandler<GetItemByIdQuery, GetItemByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetItemByIdQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
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

        // Log user interaction (view) if authenticated
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
            item.CreatedAt,
            new OwnerDto(item.Owner.FirstName, item.Owner.City, item.Owner.ProfilePictureUrl),
            item.Pricing.Select(p => new ItemPricingDto(p.PricingType, p.Price)).ToList(),
            item.Images.Select(img => new ItemImageDto(img.Id, img.Image != null ? "/" + img.Image.StoragePath.Replace("\\", "/").TrimStart('/') : "", img.IsPrimary)).ToList(),
            0, // avg rating
            0, // review count
            item.Category    != null ? new ItemCategoryRef(item.Category.Id, item.Category.NameAr, item.Category.NameEn) : null,
            item.Subcategory != null ? new ItemSubcategoryRef(item.Subcategory.Id, item.Subcategory.NameAr, item.Subcategory.NameEn) : null,
            item.Brand       != null ? new ItemBrandRef(item.Brand.Id, item.Brand.NameAr, item.Brand.NameEn) : null
        );

        return new GetItemByIdResponse(true, null, dto);
    }
}
