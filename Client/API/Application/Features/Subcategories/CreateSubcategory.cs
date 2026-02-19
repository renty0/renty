using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record CreateSubcategoryCommand(
    string NameEn, 
    string NameAr, 
    string? DescriptionEn, 
    string? DescriptionAr, 
    int CategoryId, 
    Guid? LogoId
) : IRequest<CreateSubcategoryResponse>;

public record CreateSubcategoryResponse(
    bool Success,
    string? Message,
    ProductSubcategoryDto? Subcategory
);

public class CreateSubcategoryCommandValidator : AbstractValidator<CreateSubcategoryCommand>
{
    public CreateSubcategoryCommandValidator()
    {
        RuleFor(x => x.NameEn)
            .NotEmpty().WithMessage("English subcategory name is required.")
            .MaximumLength(100).WithMessage("Subcategory name must not exceed 100 characters.");

        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Arabic subcategory name is required.")
            .MaximumLength(100).WithMessage("Subcategory name must not exceed 100 characters.");

        RuleFor(x => x.DescriptionEn)
            .MaximumLength(500).WithMessage("English description must not exceed 500 characters.");

        RuleFor(x => x.DescriptionAr)
            .MaximumLength(500).WithMessage("Arabic description must not exceed 500 characters.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Invalid category ID.");
    }
}

public class CreateSubcategoryCommandHandler : IRequestHandler<CreateSubcategoryCommand, CreateSubcategoryResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CreateSubcategoryCommandHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
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
            NameEn = request.NameEn,
            NameAr = request.NameAr,
            DescriptionEn = request.DescriptionEn,
            DescriptionAr = request.DescriptionAr,
            ProductCategoryId = request.CategoryId,
            LogoId = request.LogoId
        };

        _context.ProductSubcategories.Add(subcategory);
        await _context.SaveChangesAsync(cancellationToken);

        string? logoUrl = null;
        if (request.LogoId.HasValue) 
        {
            var logo = await _context.MediaFiles
                .AsNoTracking()
                .FirstOrDefaultAsync(m => m.Id == request.LogoId, cancellationToken);
            
            if (logo != null)
            {
                var requestUrl = _httpContextAccessor.HttpContext?.Request;
                var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;
                logoUrl = $"{baseUrl.TrimEnd('/')}/{logo.StoragePath.Replace("\\", "/").TrimStart('/')}";
            }
        }

        var category = await _context.ProductCategories.FindAsync(new object[] { request.CategoryId }, cancellationToken);
        var dto = new ProductSubcategoryDto(
            subcategory.Id,
            subcategory.NameEn,
            subcategory.NameAr,
            subcategory.DescriptionEn,
            subcategory.DescriptionAr,
            subcategory.LogoId,
            logoUrl,
            subcategory.ProductCategoryId,
            category!.NameEn,
            category!.NameAr,
            0,
            subcategory.Created,
            subcategory.LastModified
        );

        return new CreateSubcategoryResponse(true, "Subcategory created successfully.", dto);
    }
}
