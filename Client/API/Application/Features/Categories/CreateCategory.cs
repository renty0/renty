using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record CreateCategoryCommand(string CategoryName) : IRequest<CreateCategoryResponse>;

public record CreateCategoryResponse(
    bool Success,
    string? Message,
    ProductCategoryDto? Category
);

public class CreateCategoryCommandValidator : AbstractValidator<CreateCategoryCommand>
{
    public CreateCategoryCommandValidator()
    {
        RuleFor(x => x.CategoryName)
            .NotEmpty().WithMessage("Category name is required.")
            .MaximumLength(100).WithMessage("Category name must not exceed 100 characters.");
    }
}

public class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, CreateCategoryResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateCategoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateCategoryResponse> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        var exists = await _context.ProductCategories
            .AnyAsync(c => c.CategoryName == request.CategoryName, cancellationToken);

        if (exists)
        {
            return new CreateCategoryResponse(false, "A category with this name already exists.", null);
        }

        var category = new ProductCategory
        {
            CategoryName = request.CategoryName
        };

        _context.ProductCategories.Add(category);
        await _context.SaveChangesAsync(cancellationToken);

        var dto = new ProductCategoryDto(category.Id, category.CategoryName, 0);
        return new CreateCategoryResponse(true, "Category created successfully.", dto);
    }
}
