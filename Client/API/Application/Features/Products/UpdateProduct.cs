using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record UpdateProductCommand(
    long Id,
    string ProductSku,
    string NameAr,
    string NameEn,
    string? ModelName,
    string DescAr,
    string DescEn,
    string? ProductColor,
    string? ProductStyle,
    decimal ProductCost,
    decimal ProductPrice,
    string? SkuType,
    decimal? DiscountPrice,
    int SubcategoryId,
    List<UpdateProductImageDto>? Images
) : IRequest<UpdateProductResponse>;

public record UpdateProductImageDto(long Id, Guid ImageId, bool IsPrimary, int DisplayOrder);

public record UpdateProductResponse(
    bool Success,
    string? Message,
    ProductDto? Product
);

public class UpdateProductCommandValidator : AbstractValidator<UpdateProductCommand>
{
    public UpdateProductCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid product ID.");

        RuleFor(x => x.ProductSku)
            .NotEmpty().WithMessage("Product SKU is required.")
            .MaximumLength(50).WithMessage("Product SKU must not exceed 50 characters.");

        RuleFor(x => x.NameEn)
            .NotEmpty().WithMessage("Product name is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Product name (Arabic) is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.ProductCost)
            .GreaterThanOrEqualTo(0).WithMessage("Product cost must be non-negative.");

        RuleFor(x => x.ProductPrice)
            .GreaterThan(0).WithMessage("Product price must be greater than 0.");

        RuleFor(x => x.DiscountPrice)
            .LessThan(x => x.ProductPrice)
            .When(x => x.DiscountPrice.HasValue)
            .WithMessage("Discount price must be less than product price.");

        RuleFor(x => x.SubcategoryId)
            .GreaterThan(0).WithMessage("Invalid subcategory ID.");
    }
}

public class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand, UpdateProductResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateProductCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateProductResponse> Handle(UpdateProductCommand request, CancellationToken cancellationToken)
    {
        var product = await _context.Products
            .Include(p => p.Images)
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (product == null)
        {
            return new UpdateProductResponse(false, "Product not found.", null);
        }

        var skuExists = await _context.Products
            .AnyAsync(p => p.ProductSku == request.ProductSku && p.Id != request.Id, cancellationToken);

        if (skuExists)
        {
            return new UpdateProductResponse(false, "A product with this SKU already exists.", null);
        }

        var subcategory = await _context.ProductSubcategories
            .Include(s => s.Category)
            .FirstOrDefaultAsync(s => s.Id == request.SubcategoryId, cancellationToken);

        if (subcategory == null)
        {
            return new UpdateProductResponse(false, "Subcategory not found.", null);
        }

        product.ProductSku = request.ProductSku;
        product.NameAr = request.NameAr;
        product.NameEn = request.NameEn;
        product.ModelName = request.ModelName;
        product.DescAr = request.DescAr;
        product.DescEn = request.DescEn;
        product.ProductColor = request.ProductColor;
        product.ProductStyle = request.ProductStyle;
        product.ProductCost = request.ProductCost;
        product.ProductPrice = request.ProductPrice;
        product.SkuType = request.SkuType;
        product.DiscountPrice = request.DiscountPrice;
        product.ProductSubcategoryId = request.SubcategoryId;

        // Sync images
        if (request.Images != null)
        {
            // Remove deleted images
            var imageIdsToKeep = request.Images.Where(i => i.Id > 0).Select(i => i.Id).ToList();
            var imagesToRemove = product.Images.Where(i => !imageIdsToKeep.Contains(i.Id)).ToList();
            
            foreach (var image in imagesToRemove)
            {
                product.Images.Remove(image);
            }

            // Update existing and add new
            foreach (var imageDto in request.Images)
            {
                if (imageDto.Id > 0)
                {
                    var existingImage = product.Images.FirstOrDefault(i => i.Id == imageDto.Id);
                    if (existingImage != null)
                    {
                        existingImage.IsPrimary = imageDto.IsPrimary;
                        existingImage.DisplayOrder = imageDto.DisplayOrder;
                    }
                }
                else
                {
                    product.Images.Add(new ProductImage
                    {
                        ImageId = imageDto.ImageId,
                        IsPrimary = imageDto.IsPrimary,
                        DisplayOrder = imageDto.DisplayOrder
                    });
                }
            }
        }

        await _context.SaveChangesAsync(cancellationToken);

        var dto = new ProductDto(
            product.Id,
            product.ProductSku,
            product.NameAr,
            product.NameEn,
            product.ModelName,
            product.DescAr,
            product.DescEn,
            product.ProductColor,
            product.ProductStyle,
            product.ProductCost,
            product.ProductPrice,
            product.SkuType,
            product.DiscountPrice,
            product.EffectivePrice,
            product.ProfitMargin,
            product.ProductSubcategoryId,
            subcategory.NameAr,
            subcategory.NameEn,
            subcategory.Category.NameAr,
            subcategory.Category.NameEn,
            product.Created,
            product.LastModified,
            product.Images.Select(i => new ProductImageDto(i.Id, i.Image != null ? "/" + i.Image.StoragePath.Replace("\\", "/").TrimStart('/') : "", i.IsPrimary, i.DisplayOrder)).ToList()
        );

        return new UpdateProductResponse(true, "Product updated successfully.", dto);
    }
}
