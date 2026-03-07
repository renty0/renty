using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Items;

public record UpdateItemCommand(
    Guid ItemId,
    string? TitleAr,
    string? TitleEn,
    string? DescAr,
    string? DescEn,
    string? Type,
    string? Condition,
    decimal DefaultDeposit,
    string? Location,
    string? City,
    decimal? Lat,
    decimal? Lng,
    int? CategoryId,
    int? SubcategoryId,
    int? BrandId,
    List<CreateItemPricingCommand>? Pricing,
    List<CreateItemImageCommand>? Images
) : IRequest<UpdateItemResponse>;

public record UpdateItemResponse(bool Success, string? Error, ItemDetailDto? Item);

public class UpdateItemCommandValidator : AbstractValidator<UpdateItemCommand>
{
    public UpdateItemCommandValidator()
    {
        RuleFor(x => x.TitleEn).NotEmpty().MaximumLength(200);
        RuleFor(x => x.TitleAr).NotEmpty().MaximumLength(200);
        RuleFor(x => x.DefaultDeposit).GreaterThanOrEqualTo(0);
    }
}

public class UpdateItemCommandHandler : IRequestHandler<UpdateItemCommand, UpdateItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public UpdateItemCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<UpdateItemResponse> Handle(UpdateItemCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new UpdateItemResponse(false, "Unauthorized.", null);

        var item = await _context.Items
            .Include(i => i.Pricing)
            .Include(i => i.Images)
            .Include(i => i.Owner)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

        if (item == null)
            return new UpdateItemResponse(false, "Item not found.", null);

        // Owner check (admins can bypass — role checked at endpoint level)
        if (item.OwnerId != _currentUser.Id.Value)
            return new UpdateItemResponse(false, "Forbidden. You do not own this item.", null);

        if (item.Status == NewItemStatus.Rented)
            return new UpdateItemResponse(false, "Cannot edit an item while it is rented.", null);

        ItemType itemType = item.Type;
        if (request.Type != null)
            Enum.TryParse(request.Type, true, out itemType);

        item.TitleAr = request.TitleAr ?? string.Empty;
        item.TitleEn = request.TitleEn ?? string.Empty;
        item.DescAr = request.DescAr;
        item.DescEn = request.DescEn;
        item.Type = itemType;
        item.Condition = request.Condition;
        item.DefaultDeposit = request.DefaultDeposit;
        item.Location = request.Location;
        item.City = request.City;
        item.Lat = request.Lat;
        item.Lng = request.Lng;
        if (request.CategoryId.HasValue)    item.CategoryId    = request.CategoryId;
        if (request.SubcategoryId.HasValue) item.SubcategoryId = request.SubcategoryId;
        if (request.BrandId.HasValue)       item.BrandId       = request.BrandId;
        item.UpdatedAt = DateTime.UtcNow;

        // Replace pricing if provided
        if (request.Pricing != null)
        {
            _context.ItemPricings.RemoveRange(item.Pricing);
            foreach (var p in request.Pricing)
                item.Pricing.Add(new Domain.Entities.ItemPricing { Price = p.Price, PricingType = p.PricingType });
        }

        // Replace images if provided
        if (request.Images != null)
        {
            _context.ItemImages.RemoveRange(item.Images);
            foreach (var img in request.Images)
                item.Images.Add(new Domain.Entities.ItemImage { ImageId = img.ImageId, IsPrimary = img.IsPrimary });
        }

        await _context.SaveChangesAsync(ct);

        var dto = new ItemDetailDto(
            item.Id, item.TitleAr, item.TitleEn, item.DescAr, item.DescEn,
            item.Type.ToString(), item.Status.ToString(), item.Condition,
            item.DefaultDeposit, item.Location, item.City, item.Lat, item.Lng,
            item.CreatedAt,
            new OwnerDto(item.Owner.FirstName, item.Owner.City, item.Owner.ProfilePictureUrl),
            item.Pricing.Select(p => new ItemPricingDto(p.PricingType, p.Price)).ToList(),
            item.Images.Select(img => new ItemImageDto(img.Id, img.Image?.StoragePath ?? "", img.IsPrimary)).ToList(),
            0, 0,
            null, null, null   // Category/Subcategory/Brand refreshed on next fetch
        );

        return new UpdateItemResponse(true, null, dto);
    }
}
