using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record CreateCategoryCommand(
    string NameEn, 
    string NameAr, 
    string? DescriptionEn, 
    string? DescriptionAr, 
    Guid? LogoId
) : IRequest<CreateCategoryResponse>;

public record CreateCategoryResponse(
    bool Success,
    string? Message,
    ProductCategoryDto? Category
);

public class CreateCategoryCommandValidator : AbstractValidator<CreateCategoryCommand>
{
    public CreateCategoryCommandValidator()
    {
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

public class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, CreateCategoryResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CreateCategoryCommandHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<CreateCategoryResponse> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        var exists = await _context.ProductCategories
            .AnyAsync(c => c.NameEn == request.NameEn, cancellationToken);

        if (exists)
        {
            return new CreateCategoryResponse(false, "A category with this name already exists.", null);
        }

        var category = new ProductCategory
        {
            NameEn = request.NameEn,
            NameAr = request.NameAr,
            DescriptionEn = request.DescriptionEn,
            DescriptionAr = request.DescriptionAr,
            LogoId = request.LogoId
        };

        _context.ProductCategories.Add(category);
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
                logoUrl = $"{baseUrl.TrimEnd('/')}/{logo.StoragePath.Replace("\\", "/").TrimStart('/')}"; // Consider extracting this logic to a helper
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
            0, 
            category.Created, 
            category.LastModified
        );
        return new CreateCategoryResponse(true, "Category created successfully.", dto);
    }
}
