using Application.Common.Interfaces;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

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
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UpdateItemCommandHandler(IApplicationDbContext context, IUser currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<UpdateItemResponse> Handle(UpdateItemCommand request, CancellationToken ct)
    {
        try {
            if (_currentUser.Id == null)
                return new UpdateItemResponse(false, "Unauthorized.", null);

            var item = await _context.Items
                .Include(i => i.Pricing)
                .Include(i => i.Images)
                    .ThenInclude(img => img.Image)
                .Include(i => i.Owner)
                .FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);

            if (item == null)
                return new UpdateItemResponse(false, "Item not found.", null);

            var isAdmin = _httpContextAccessor.HttpContext?.User?.IsInRole("Admin") ?? false;
            if (!isAdmin && item.OwnerId != _currentUser.Id.Value)
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

            // Update Pricing
            if (request.Pricing != null)
            {
                var inputPrices = request.Pricing.ToList();
                var currentPricings = item.Pricing.ToList();

                // 1. Remove orphaned pricings
                var inputTypes = inputPrices.Select(p => p.PricingType).ToHashSet();
                foreach (var existing in currentPricings)
                {
                    if (!inputTypes.Contains(existing.PricingType))
                    {
                        _context.ItemPricings.Remove(existing);
                    }
                }

                // 2. Update existing or add new
                foreach (var input in inputPrices)
                {
                    // Find ALL existing matches for this type to handle potential duplicates in DB
                    var matches = currentPricings.Where(p => p.PricingType == input.PricingType).ToList();
                    if (matches.Any())
                    {
                        // Update the first one
                        matches[0].Price = input.Price;
                        // Remove others if they exist (duplicates)
                        for (int i = 1; i < matches.Count; i++)
                        {
                            _context.ItemPricings.Remove(matches[i]);
                        }
                    }
                    else
                    {
                        _context.ItemPricings.Add(new Domain.Entities.ItemPricing 
                        { 
                            Price = input.Price, 
                            PricingType = input.PricingType,
                            ItemId = item.Id
                        });
                    }
                }
            }

            // Update Images
            if (request.Images != null)
            {
                var inputImages = request.Images.ToList();
                var currentImages = item.Images.ToList();

                // 1. Remove orphaned images
                var inputImgIds = inputImages.Select(img => img.ImageId).ToHashSet();
                foreach (var existing in currentImages)
                {
                    if (!inputImgIds.Contains(existing.ImageId))
                    {
                        _context.ItemImages.Remove(existing);
                    }
                }

                // 2. Update existing or add new
                foreach (var input in inputImages)
                {
                    var matches = currentImages.Where(img => img.ImageId == input.ImageId).ToList();
                    if (matches.Any())
                    {
                        // Update the first one
                        matches[0].IsPrimary = input.IsPrimary;
                        // Remove others if they exist (duplicates)
                        for (int i = 1; i < matches.Count; i++)
                        {
                            _context.ItemImages.Remove(matches[i]);
                        }
                    }
                    else
                    {
                        _context.ItemImages.Add(new Domain.Entities.ItemImage 
                        { 
                            ImageId = input.ImageId, 
                            IsPrimary = input.IsPrimary,
                            ItemId = item.Id
                        });
                    }
                }
            }

            try
            {
                await _context.SaveChangesAsync(ct);
            }
            catch (DbUpdateConcurrencyException ex)
            {
                var entry = ex.Entries.FirstOrDefault();
                var entityName = entry?.Entity.GetType().Name ?? "Unknown";
                var id = entry?.Property("Id").CurrentValue?.ToString() ?? "Unknown";
                var state = entry?.State.ToString() ?? "Unknown";
                var errorMsg = $"Concurrency Exception on {entityName} ID: {id} (State: {state}): {ex.Message}";
                System.IO.File.WriteAllText("UpdateItemConcurrencyError.txt", $"{errorMsg}\n{ex.StackTrace}");
                return new UpdateItemResponse(false, errorMsg, null);
            }
            catch (Exception ex)
            {
                System.IO.File.WriteAllText("UpdateItemErrorDump.txt", ex.ToString());
                return new UpdateItemResponse(false, $"Database Exception: {ex.Message}", null);
            }

            var dto = new ItemDetailDto(
                item.Id, item.TitleAr, item.TitleEn, item.DescAr, item.DescEn,
                item.Type.ToString(), item.Status.ToString(), item.Condition,
                item.DefaultDeposit, item.Location, item.City, item.Lat, item.Lng,
                item.IsForSale, item.SalePrice,
                item.CreatedAt,
                new OwnerDto(
                    item.OwnerId, 
                    item.Owner.FirstName, 
                    item.Owner.LastName,
                    item.Owner.City, 
                    item.Owner.ProfilePictureUrl,
                    item.Owner.Rating,
                    item.Owner.TotalRatings),
                item.Pricing.Select(p => new ItemPricingDto(p.PricingType, p.Price)).ToList(),
                item.Images.Select(img => new ItemImageDto(img.ImageId, img.Image?.StoragePath ?? "", img.IsPrimary)).ToList(),
                0, 0,
                item.Category != null ? new ItemCategoryRef(item.Category.Id, item.Category.NameAr, item.Category.NameEn) : null,
                item.Subcategory != null ? new ItemSubcategoryRef(item.Subcategory.Id, item.Subcategory.NameAr, item.Subcategory.NameEn) : null,
                item.Brand != null ? new ItemBrandRef(item.Brand.Id, item.Brand.NameAr, item.Brand.NameEn) : null
            );

            return new UpdateItemResponse(true, null, dto);
        } catch (Exception fullEx) {
            System.IO.File.WriteAllText("UpdateItemErrorDumpFull.txt", fullEx.ToString());
            return new UpdateItemResponse(false, $"Exception2: {fullEx.Message} Inner: {fullEx.InnerException?.Message}", null);
        }
    }
}
