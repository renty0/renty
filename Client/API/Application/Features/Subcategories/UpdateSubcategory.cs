using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record UpdateSubcategoryCommand(int Id, string SubcategoryName, int CategoryId) : IRequest<UpdateSubcategoryResponse>;

public record UpdateSubcategoryResponse(
    bool Success,
    string? Message,
    ProductSubcategoryDto? Subcategory
);

public class UpdateSubcategoryCommandValidator : AbstractValidator<UpdateSubcategoryCommand>
{
    public UpdateSubcategoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid subcategory ID.");

        RuleFor(x => x.SubcategoryName)
            .NotEmpty().WithMessage("Subcategory name is required.")
            .MaximumLength(100).WithMessage("Subcategory name must not exceed 100 characters.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Invalid category ID.");
    }
}

public class UpdateSubcategoryCommandHandler : IRequestHandler<UpdateSubcategoryCommand, UpdateSubcategoryResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateSubcategoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateSubcategoryResponse> Handle(UpdateSubcategoryCommand request, CancellationToken cancellationToken)
    {
        var subcategory = await _context.ProductSubcategories
            .Include(s => s.Category)
            .Include(s => s.Products)
            .FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);

        if (subcategory == null)
        {
            return new UpdateSubcategoryResponse(false, "Subcategory not found.", null);
        }

        var categoryExists = await _context.ProductCategories
            .AnyAsync(c => c.Id == request.CategoryId, cancellationToken);

        if (!categoryExists)
        {
            return new UpdateSubcategoryResponse(false, "Category not found.", null);
        }

        subcategory.SubcategoryName = request.SubcategoryName;
        subcategory.ProductCategoryId = request.CategoryId;
        await _context.SaveChangesAsync(cancellationToken);

        var category = await _context.ProductCategories.FindAsync(new object[] { request.CategoryId }, cancellationToken);
        var dto = new ProductSubcategoryDto(
            subcategory.Id,
            subcategory.SubcategoryName,
            subcategory.ProductCategoryId,
            category!.CategoryName,
            subcategory.Products.Count
        );

        return new UpdateSubcategoryResponse(true, "Subcategory updated successfully.", dto);
    }
}
