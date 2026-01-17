using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record CreateProductCommand(
    string ProductSku,
    string ProductName,
    string? ModelName,
    string? ProductDescription,
    string? ProductColor,
    string? ProductStyle,
    decimal ProductCost,
    decimal ProductPrice,
    string? SkuType,
    decimal? DiscountPrice,
    int SubcategoryId,
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

        RuleFor(x => x.ProductName)
            .NotEmpty().WithMessage("Product name is required.")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters.");

        RuleFor(x => x.ModelName)
            .MaximumLength(100).WithMessage("Model name must not exceed 100 characters.");

        RuleFor(x => x.ProductDescription)
            .MaximumLength(1000).WithMessage("Product description must not exceed 1000 characters.");

        RuleFor(x => x.ProductColor)
            .MaximumLength(50).WithMessage("Product color must not exceed 50 characters.");

        RuleFor(x => x.ProductStyle)
            .MaximumLength(50).WithMessage("Product style must not exceed 50 characters.");

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

        var product = new Product
        {
            ProductSku = request.ProductSku,
            ProductName = request.ProductName,
            ModelName = request.ModelName,
            ProductDescription = request.ProductDescription,
            ProductColor = request.ProductColor,
            ProductStyle = request.ProductStyle,
            ProductCost = request.ProductCost,
            ProductPrice = request.ProductPrice,
            SkuType = request.SkuType,
            DiscountPrice = request.DiscountPrice,
            ProductSubcategoryId = request.SubcategoryId
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
            product.ProductName,
            product.ModelName,
            product.ProductDescription,
            product.ProductColor,
            product.ProductStyle,
            product.ProductCost,
            product.ProductPrice,
            product.SkuType,
            product.DiscountPrice,
            product.EffectivePrice,
            product.ProfitMargin,
            product.ProductSubcategoryId,
            subcategory.SubcategoryName,
            subcategory.Category.CategoryName,
            product.Created,
            product.LastModified,
            product.Images.Select(i => new ProductImageDto(i.Id, i.ImageUrl, i.IsPrimary, i.DisplayOrder)).ToList()
        );

        return new CreateProductResponse(true, "Product created successfully.", dto);
    }
}
