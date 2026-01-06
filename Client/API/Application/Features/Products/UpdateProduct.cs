using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record UpdateProductCommand(
    long Id,
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
    int SubcategoryId
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

        RuleFor(x => x.ProductName)
            .NotEmpty().WithMessage("Product name is required.")
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
        product.ProductName = request.ProductName;
        product.ModelName = request.ModelName;
        product.ProductDescription = request.ProductDescription;
        product.ProductColor = request.ProductColor;
        product.ProductStyle = request.ProductStyle;
        product.ProductCost = request.ProductCost;
        product.ProductPrice = request.ProductPrice;
        product.SkuType = request.SkuType;
        product.DiscountPrice = request.DiscountPrice;
        product.ProductSubcategoryId = request.SubcategoryId;

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
            subcategory.Category.CategoryName
        );

        return new UpdateProductResponse(true, "Product updated successfully.", dto);
    }
}
