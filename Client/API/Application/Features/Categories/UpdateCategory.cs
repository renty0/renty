using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record UpdateCategoryCommand(int Id, string CategoryName, string? Description, Guid? LogoId) : IRequest<UpdateCategoryResponse>;

public record UpdateCategoryResponse(
    bool Success,
    string? Message,
    ProductCategoryDto? Category
);

public class UpdateCategoryCommandValidator : AbstractValidator<UpdateCategoryCommand>
{
    public UpdateCategoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid category ID.");

        RuleFor(x => x.CategoryName)
            .NotEmpty().WithMessage("Category name is required.")
            .MaximumLength(100).WithMessage("Category name must not exceed 100 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Description must not exceed 500 characters.");
    }
}

public class UpdateCategoryCommandHandler : IRequestHandler<UpdateCategoryCommand, UpdateCategoryResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateCategoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateCategoryResponse> Handle(UpdateCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _context.ProductCategories
            .Include(c => c.Subcategories)
            .Include(c => c.Logo)
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);

        if (category == null)
        {
            return new UpdateCategoryResponse(false, "Category not found.", null);
        }

        var nameExists = await _context.ProductCategories
            .AnyAsync(c => c.CategoryName == request.CategoryName && c.Id != request.Id, cancellationToken);

        if (nameExists)
        {
            return new UpdateCategoryResponse(false, "A category with this name already exists.", null);
        }

        category.CategoryName = request.CategoryName;
        category.Description = request.Description ?? string.Empty;
        category.LogoId = request.LogoId;
        
        await _context.SaveChangesAsync(cancellationToken);

        // Assuming baseUrl needs to be passed or handled. For now, skipping full URL construction or using helper.
        // We can just pass the storage path or something, but the DTO expects nullable string usage.
        // Let's use Logo.StoragePath if available.
        string? logoUrl = category.Logo?.StoragePath; 

        var dto = new ProductCategoryDto(category.Id, category.CategoryName, category.Description, category.LogoId, logoUrl, category.Subcategories.Count);
        return new UpdateCategoryResponse(true, "Category updated successfully.", dto);
    }
}
