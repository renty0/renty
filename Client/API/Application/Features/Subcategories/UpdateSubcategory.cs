using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Common;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

using Microsoft.AspNetCore.Http;

namespace Application.Features.Subcategories;

public record UpdateSubcategoryCommand(int Id, string NameAr, string NameEn, string? DescAr, string? DescEn, int CategoryId, Guid? LogoId) : IRequest<UpdateSubcategoryResponse>;

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

        RuleFor(x => x.NameEn)
            .NotEmpty().WithMessage("Subcategory English name is required.")
            .MaximumLength(100).WithMessage("Subcategory English name must not exceed 100 characters.");
            
        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Subcategory Arabic name is required.")
            .MaximumLength(100).WithMessage("Subcategory Arabic name must not exceed 100 characters.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Invalid category ID.");
    }
}

public class UpdateSubcategoryCommandHandler : IRequestHandler<UpdateSubcategoryCommand, UpdateSubcategoryResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UpdateSubcategoryCommandHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
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

        subcategory.NameAr = request.NameAr ?? string.Empty;
        subcategory.NameEn = request.NameEn ?? string.Empty;
        subcategory.DescAr = request.DescAr;
        subcategory.DescEn = request.DescEn;
        subcategory.ProductCategoryId = request.CategoryId;
        subcategory.LogoId = request.LogoId;
        
        await _context.SaveChangesAsync(cancellationToken);

        string? logoUrl = null;
        if (subcategory.LogoId.HasValue) 
        {
            var logo = await _context.MediaFiles
                .AsNoTracking()
                .FirstOrDefaultAsync(m => m.Id == subcategory.LogoId, cancellationToken);
            
            if (logo != null)
            {
                var requestUrl = _httpContextAccessor.HttpContext?.Request;
                var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;
                logoUrl = logo.StoragePath.ToAbsoluteUrl(baseUrl);
            }
        }

        var dto = new ProductSubcategoryDto(
            subcategory.Id,
            subcategory.NameAr,
            subcategory.NameEn,
            subcategory.DescAr,
            subcategory.DescEn,
            subcategory.LogoId,
            logoUrl,
            subcategory.ProductCategoryId,
            subcategory.Category?.NameAr ?? "",
            subcategory.Category?.NameEn ?? "",
            subcategory.Products.Count,
            subcategory.Created,
            subcategory.LastModified
        );

        return new UpdateSubcategoryResponse(true, "Subcategory updated successfully.", dto);
    }
}
