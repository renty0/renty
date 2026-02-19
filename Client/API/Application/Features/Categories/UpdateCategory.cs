using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record UpdateCategoryCommand(
    int Id, 
    string NameEn, 
    string NameAr, 
    string? DescriptionEn, 
    string? DescriptionAr, 
    Guid? LogoId
) : IRequest<UpdateCategoryResponse>;

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

        RuleFor(x => x.NameEn)
            .NotEmpty().WithMessage("English category name is required.")
            .MaximumLength(100).WithMessage("Category name must not exceed 100 characters.");

        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Arabic category name is required.")
            .MaximumLength(100).WithMessage("Category name must not exceed 100 characters.");

        RuleFor(x => x.DescriptionEn)
            .MaximumLength(500).WithMessage("English description must not exceed 500 characters.");

        RuleFor(x => x.DescriptionAr)
            .MaximumLength(500).WithMessage("Arabic description must not exceed 500 characters.");
    }
}

public class UpdateCategoryCommandHandler : IRequestHandler<UpdateCategoryCommand, UpdateCategoryResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UpdateCategoryCommandHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
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
            .AnyAsync(c => c.NameEn == request.NameEn && c.Id != request.Id, cancellationToken);

        if (nameExists)
        {
            return new UpdateCategoryResponse(false, "A category with this name already exists.", null);
        }

        category.NameEn = request.NameEn;
        category.NameAr = request.NameAr;
        category.DescriptionEn = request.DescriptionEn;
        category.DescriptionAr = request.DescriptionAr;
        category.LogoId = request.LogoId;
        
        await _context.SaveChangesAsync(cancellationToken);

        string? logoUrl = null;
        if (category.LogoId.HasValue)
        {
            // If the logo was changed, category.Logo might still be the old one.
            // Let's fetch the actual logo to be sure.
            var logo = await _context.MediaFiles
                .AsNoTracking()
                .FirstOrDefaultAsync(m => m.Id == category.LogoId, cancellationToken);
                
            if (logo != null)
            {
                var requestUrl = _httpContextAccessor.HttpContext?.Request;
                var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;
                logoUrl = $"{baseUrl.TrimEnd('/')}/{logo.StoragePath.Replace("\\", "/").TrimStart('/')}";
            }
        }

        var dto = new ProductCategoryDto(
            category.Id, 
            category.NameEn, 
            category.NameAr, 
            category.DescriptionEn, 
            category.DescriptionAr, 
            category.LogoId, 
            logoUrl, 
            category.Subcategories.Count, 
            category.Created, 
            category.LastModified
        );
        return new UpdateCategoryResponse(true, "Category updated successfully.", dto);
    }
}
