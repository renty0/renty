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
    string NameEn,
    string NameAr,
    string? ModelName,
    string? DescriptionEn,
    string? DescriptionAr,
    string? Color,
    string? Style,
    decimal ProductCost,
    decimal RentPricePerDay,
    string? SkuType,
    decimal? RentDiscountPrice,
    int SubcategoryId,
    int? BrandId,
    List<ProductImageDto>? Images
) : IRequest<UpdateProductResponse>;

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
            .NotEmpty().WithMessage("English product name is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Arabic product name is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.ProductCost)
            .GreaterThanOrEqualTo(0).WithMessage("Product cost must be non-negative.");

        RuleFor(x => x.RentPricePerDay)
            .GreaterThan(0).WithMessage("Rent price must be greater than 0.");

        RuleFor(x => x.RentDiscountPrice)
            .LessThan(x => x.RentPricePerDay)
            .When(x => x.RentDiscountPrice.HasValue)
            .WithMessage("Discount price must be less than rent price.");

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

        Brand? brand = null;
        if (request.BrandId.HasValue)
        {
             brand = await _context.Brands.FindAsync(new object[] { request.BrandId.Value }, cancellationToken);
             if (brand == null)
             {
                 return new UpdateProductResponse(false, "Brand not found.", null);
             }
        }

        product.ProductSku = request.ProductSku;
        product.NameEn = request.NameEn;
        product.NameAr = request.NameAr;
        product.ModelName = request.ModelName;
        product.DescriptionEn = request.DescriptionEn;
        product.DescriptionAr = request.DescriptionAr;
        product.Color = request.Color;
        product.Style = request.Style;
        product.ProductCost = request.ProductCost;
        product.RentPricePerDay = request.RentPricePerDay;
        product.SkuType = request.SkuType;
        product.RentDiscountPrice = request.RentDiscountPrice;
        product.ProductSubcategoryId = request.SubcategoryId;
        product.BrandId = request.BrandId;

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
                        ImageUrl = imageDto.ImageUrl,
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
            product.NameEn,
            product.NameAr,
            product.ModelName,
            product.DescriptionEn,
            product.DescriptionAr,
            product.Color,
            product.Style,
            product.ProductCost,
            product.RentPricePerDay,
            product.SkuType,
            product.RentDiscountPrice,
            product.EffectivePrice,
            product.ProfitMargin,
            product.ProductSubcategoryId,
            subcategory.NameEn,
            subcategory.NameAr,
            subcategory.Category.NameEn,
            subcategory.Category.NameAr,
            product.BrandId,
            brand?.NameEn,
            brand?.NameAr,
            product.Created,
            product.LastModified,
            product.Images.Select(i => new ProductImageDto(i.Id, i.ImageUrl, i.IsPrimary, i.DisplayOrder)).ToList()
        );

        return new UpdateProductResponse(true, "Product updated successfully.", dto);
    }
}
