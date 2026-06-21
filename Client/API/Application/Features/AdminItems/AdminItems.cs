using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

using Application.Features.Items;
using Microsoft.AspNetCore.Http;

namespace Application.Features.AdminItems;

// ── REVIEW ITEM ───────────────────────────────────────────────────────────────

public record ReviewItemCommand(Guid ItemId, string Status, string? RejectionReason) : IRequest<ReviewItemResponse>;
public record ReviewItemResponse(bool Success, string? Error);

public class ReviewItemCommandHandler : IRequestHandler<ReviewItemCommand, ReviewItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificationSender _notifier;

    public ReviewItemCommandHandler(IApplicationDbContext context, INotificationSender notifier)
    {
        _context = context;
        _notifier = notifier;
    }

    public async Task<ReviewItemResponse> Handle(ReviewItemCommand request, CancellationToken ct)
    {
        var item = await _context.Items.FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);
        if (item == null) return new ReviewItemResponse(false, "Item not found.");

        string notificationTitle;
        string notificationMessage;
        string notificationTitleAr;
        string notificationMessageAr;
        if (request.Status == "approved")
        {
            item.Status = NewItemStatus.Available;
            item.AdminNote = null;
            notificationTitle = "Item approved";
            notificationMessage = $"Your item \"{item.TitleEn}\" has been approved and is now live.";
            notificationTitleAr = "تمت الموافقة على المنتج";
            notificationMessageAr = $"تمت الموافقة على منتجك \"{item.TitleEn}\" وهو متاح الآن.";
        }
        else if (request.Status == "rejected")
        {
            item.Status = NewItemStatus.Suspended;
            item.AdminNote = request.RejectionReason;
            notificationTitle = "Item rejected";
            var reasonSuffix = string.IsNullOrWhiteSpace(request.RejectionReason)
                ? string.Empty
                : $" Reason: {request.RejectionReason}";
            notificationMessage = $"Your item \"{item.TitleEn}\" was rejected by admin.{reasonSuffix}";
            notificationTitleAr = "تم رفض المنتج";
            var reasonSuffixAr = string.IsNullOrWhiteSpace(request.RejectionReason)
                ? string.Empty
                : $" السبب: {request.RejectionReason}";
            notificationMessageAr = $"تم رفض منتجك \"{item.TitleEn}\" من قبل الإدارة.{reasonSuffixAr}";
        }
        else
        {
            return new ReviewItemResponse(false, "Status must be 'approved' or 'rejected'.");
        }

        await _context.SaveChangesAsync(ct);

        if (item.OwnerId > 0)
        {
            await _notifier.SendToUserAsync(
                item.OwnerId,
                notificationTitle,
                notificationMessage,
                "item",
                $"/items/{item.Id}",
                ct,
                titleAr: notificationTitleAr,
                messageAr: notificationMessageAr);
        }

        return new ReviewItemResponse(true, null);
    }
}

// ── GET PENDING ITEMS ────────────────────────────────────────────────────────

public record GetPendingItemsQuery() : IRequest<List<ItemListDto>>;

public class GetPendingItemsQueryHandler : IRequestHandler<GetPendingItemsQuery, List<ItemListDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetPendingItemsQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<List<ItemListDto>> Handle(GetPendingItemsQuery request, CancellationToken ct)
    {
        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : null;

        var items = await _context.Items
            .Include(i => i.Category)
            .Include(i => i.Subcategory)
            .Include(i => i.Brand)
            .Where(i => i.Status == NewItemStatus.UnderReview)
            .Select(i => new
            {
                Item = i,
                DailyPrice = i.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                PrimaryImage = i.Images.Where(img => img.IsPrimary).Select(img => img.Image.StoragePath).FirstOrDefault()
                    ?? i.Images.Select(img => img.Image.StoragePath).FirstOrDefault()
            })
            .ToListAsync(ct);

        return items.Select(x => new ItemListDto(
            x.Item.Id,
            x.Item.TitleAr,
            x.Item.TitleEn,
            x.DailyPrice,
            x.Item.City,
            x.PrimaryImage != null ? (string.IsNullOrEmpty(baseUrl) ? "/" + x.PrimaryImage.Replace("\\\\", "/").TrimStart('/') : baseUrl.TrimEnd('/') + "/" + x.PrimaryImage.Replace("\\\\", "/").TrimStart('/')) : null,
            0,
            0,
            x.Item.Type.ToString(),
            x.Item.Condition,
            x.Item.OwnerId,
            x.Item.IsForSale,
            x.Item.SalePrice,
            x.Item.Status.ToString(),
            x.Item.CreatedAt,
            x.Item.Category != null ? new ItemCategoryRef(x.Item.Category.Id, x.Item.Category.NameAr, x.Item.Category.NameEn) : null,
            x.Item.Subcategory != null ? new ItemSubcategoryRef(x.Item.Subcategory.Id, x.Item.Subcategory.NameAr, x.Item.Subcategory.NameEn) : null,
            x.Item.Brand != null ? new ItemBrandRef(x.Item.Brand.Id, x.Item.Brand.NameAr, x.Item.Brand.NameEn) : null
        )).ToList();
    }
}
