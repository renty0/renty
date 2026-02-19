using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record CreateProductCommand(
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
    List<string>? ImageUrls
) : IRequest<CreateProductResponse>;

public record CreateProductResponse(
    bool Success,
    string? Message,
    ProductDto? Product
);

public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.ProductSku)
            .NotEmpty().WithMessage("Product SKU is required.")
            .MaximumLength(50).WithMessage("Product SKU must not exceed 50 characters.");

        RuleFor(x => x.NameEn)
            .NotEmpty().WithMessage("English product name is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Arabic product name is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.ModelName)
            .MaximumLength(100).WithMessage("Model name must not exceed 100 characters.");

        RuleFor(x => x.DescriptionEn)
            .MaximumLength(1000).WithMessage("English product description must not exceed 1000 characters.");

        RuleFor(x => x.DescriptionAr)
            .MaximumLength(1000).WithMessage("Arabic product description must not exceed 1000 characters.");

        RuleFor(x => x.Color)
            .MaximumLength(50).WithMessage("Product color must not exceed 50 characters.");

        RuleFor(x => x.Style)
            .MaximumLength(50).WithMessage("Product style must not exceed 50 characters.");

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

public class CreateProductCommandHandler : IRequestHandler<CreateProductCommand, CreateProductResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateProductCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateProductResponse> Handle(CreateProductCommand request, CancellationToken cancellationToken)
    {
        var skuExists = await _context.Products
            .AnyAsync(p => p.ProductSku == request.ProductSku, cancellationToken);

        if (skuExists)
        {
            return new CreateProductResponse(false, "A product with this SKU already exists.", null);
        }

        var subcategory = await _context.ProductSubcategories
            .Include(s => s.Category)
            .FirstOrDefaultAsync(s => s.Id == request.SubcategoryId, cancellationToken);

        if (subcategory == null)
        {
            return new CreateProductResponse(false, "Subcategory not found.", null);
        }

        Brand? brand = null;
        if (request.BrandId.HasValue)
        {
             brand = await _context.Brands.FindAsync(new object[] { request.BrandId.Value }, cancellationToken);
             if (brand == null)
             {
                 return new CreateProductResponse(false, "Brand not found.", null);
             }
        }

        var product = new Product
        {
            ProductSku = request.ProductSku,
            NameEn = request.NameEn,
            NameAr = request.NameAr,
            ModelName = request.ModelName,
            DescriptionEn = request.DescriptionEn,
            DescriptionAr = request.DescriptionAr,
            Color = request.Color,
            Style = request.Style,
            ProductCost = request.ProductCost,
            RentPricePerDay = request.RentPricePerDay,
            SkuType = request.SkuType,
            RentDiscountPrice = request.RentDiscountPrice,
            ProductSubcategoryId = request.SubcategoryId,
            BrandId = request.BrandId
        };

        if (request.ImageUrls != null && request.ImageUrls.Any())
        {
            for (int i = 0; i < request.ImageUrls.Count; i++)
            {
                product.Images.Add(new ProductImage
                {
                    ImageUrl = request.ImageUrls[i],
                    IsPrimary = i == 0,
                    DisplayOrder = i
                });
            }
        }

        _context.Products.Add(product);
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

        return new CreateProductResponse(true, "Product created successfully.", dto);
    }
}
