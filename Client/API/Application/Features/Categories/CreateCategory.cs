using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record CreateCategoryCommand(string CategoryName, string? Description, Guid? LogoId) : IRequest<CreateCategoryResponse>;

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
            
        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Description must not exceed 500 characters.");
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
            CategoryName = request.CategoryName,
            Description = request.Description ?? string.Empty,
            LogoId = request.LogoId
        };

        _context.ProductCategories.Add(category);
        await _context.SaveChangesAsync(cancellationToken);

        // Fetch category with logo to get URL if needed, but for create, we might just return what we have (or null URL)
        // If LogoId is present, we might want to include the Logo entity to get the URL, but simplified for now.
        // Assuming GetFullUrl extension needs MediaFile entity.
        // For now, return DTO with simplified logo URL or empty.
        
        string? logoUrl = null;
        if (request.LogoId.HasValue) 
        {
            // Ideally we load the logo, but for performance on create we might skip or load it.
            // Let's keep it simple for now.
        }

        var dto = new ProductCategoryDto(category.Id, category.CategoryName, category.Description, category.LogoId, logoUrl, 0);
        return new CreateCategoryResponse(true, "Category created successfully.", dto);
    }
}
