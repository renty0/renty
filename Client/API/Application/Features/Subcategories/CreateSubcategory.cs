using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record CreateSubcategoryCommand(string SubcategoryName, int CategoryId) : IRequest<CreateSubcategoryResponse>;

public record CreateSubcategoryResponse(
    bool Success,
    string? Message,
    ProductSubcategoryDto? Subcategory
);

public class CreateSubcategoryCommandValidator : AbstractValidator<CreateSubcategoryCommand>
{
    public CreateSubcategoryCommandValidator()
    {
        RuleFor(x => x.SubcategoryName)
            .NotEmpty().WithMessage("Subcategory name is required.")
            .MaximumLength(100).WithMessage("Subcategory name must not exceed 100 characters.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Invalid category ID.");
    }
}

public class CreateSubcategoryCommandHandler : IRequestHandler<CreateSubcategoryCommand, CreateSubcategoryResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateSubcategoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateSubcategoryResponse> Handle(CreateSubcategoryCommand request, CancellationToken cancellationToken)
    {
        var categoryExists = await _context.ProductCategories
            .AnyAsync(c => c.Id == request.CategoryId, cancellationToken);

        if (!categoryExists)
        {
            return new CreateSubcategoryResponse(false, "Category not found.", null);
        }

        var subcategory = new ProductSubcategory
        {
            SubcategoryName = request.SubcategoryName,
            ProductCategoryId = request.CategoryId
        };

        _context.ProductSubcategories.Add(subcategory);
        await _context.SaveChangesAsync(cancellationToken);

        var category = await _context.ProductCategories.FindAsync(new object[] { request.CategoryId }, cancellationToken);
        var dto = new ProductSubcategoryDto(
            subcategory.Id,
            subcategory.SubcategoryName,
            subcategory.ProductCategoryId,
            category!.CategoryName,
            0
        );

        return new CreateSubcategoryResponse(true, "Subcategory created successfully.", dto);
    }
}
