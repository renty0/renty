using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;

namespace Application.Features.Items;

public record CreateItemPricingCommand(decimal Price, string PricingType);
public record CreateItemImageCommand(Guid ImageId, bool IsPrimary);

public record CreateItemCommand(
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
    List<CreateItemPricingCommand> Pricing,
    List<CreateItemImageCommand> Images
) : IRequest<CreateItemResponse>;

public record CreateItemResponse(bool Success, string? Error, Guid? ItemId);

public class CreateItemCommandValidator : AbstractValidator<CreateItemCommand>
{
    public CreateItemCommandValidator()
    {
        RuleFor(x => x.TitleEn).NotEmpty().MaximumLength(200);
        RuleFor(x => x.TitleAr).NotEmpty().MaximumLength(200);
        RuleFor(x => x.TitleAr).NotEmpty().MaximumLength(200);
        RuleFor(x => x.DefaultDeposit).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Pricing).NotEmpty().WithMessage("At least one pricing entry is required.");
        RuleFor(x => x.Images).NotEmpty().WithMessage("At least one image is required.");
        RuleFor(x => x.Images)
            .Must(images => images != null && images.Any(i => i.IsPrimary))
            .WithMessage("One image must be marked as primary.");
        RuleForEach(x => x.Pricing).ChildRules(p =>
        {
            p.RuleFor(x => x.Price).GreaterThan(0);
            p.RuleFor(x => x.PricingType).Must(t => t == "daily" || t == "weekly" || t == "monthly")
                .WithMessage("PricingType must be daily, weekly, or monthly.");
        });
    }
}

public class CreateItemCommandHandler : IRequestHandler<CreateItemCommand, CreateItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public CreateItemCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreateItemResponse> Handle(CreateItemCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateItemResponse(false, "Unauthorized.", null);

        ItemType itemType = ItemType.Standard;
        if (request.Type != null)
            Enum.TryParse(request.Type, true, out itemType);

        var item = new Item
        {
            OwnerId = _currentUser.Id.Value,
            TitleAr = request.TitleAr ?? string.Empty,
            TitleEn = request.TitleEn ?? string.Empty,
            DescAr = request.DescAr,
            DescEn = request.DescEn,
            Type = itemType,
            Status = NewItemStatus.Available,
            Condition = request.Condition,
            DefaultDeposit = request.DefaultDeposit,
            Location = request.Location,
            City = request.City,
            Lat = request.Lat,
            Lng = request.Lng,
            CategoryId    = request.CategoryId,
            SubcategoryId = request.SubcategoryId,
            BrandId       = request.BrandId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        foreach (var p in request.Pricing)
            item.Pricing.Add(new ItemPricing { Price = p.Price, PricingType = p.PricingType });

        foreach (var img in request.Images)
            item.Images.Add(new ItemImage { ImageId = img.ImageId, IsPrimary = img.IsPrimary });

        _context.Items.Add(item);
        await _context.SaveChangesAsync(ct);

        return new CreateItemResponse(true, null, item.Id);
    }
}
