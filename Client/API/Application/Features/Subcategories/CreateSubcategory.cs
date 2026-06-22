using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Common;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record CreateSubcategoryCommand(string NameAr, string NameEn, string? DescAr, string? DescEn, int CategoryId, Guid? LogoId) : IRequest<CreateSubcategoryResponse>;

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
            .NotEmpty().WithMessage("Subcategory English name is required.")
            .MaximumLength(100).WithMessage("Subcategory English name must not exceed 100 characters.");
            
        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Subcategory Arabic name is required.")
            .MaximumLength(100).WithMessage("Subcategory Arabic name must not exceed 100 characters.");

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
            NameAr = request.NameAr ?? string.Empty,
            NameEn = request.NameEn ?? string.Empty,
            DescAr = request.DescAr,
            DescEn = request.DescEn,
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
                logoUrl = logo.StoragePath.ToAbsoluteUrl(baseUrl);
            }
        }

        var category = await _context.ProductCategories
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == request.CategoryId, cancellationToken);

        var dto = new ProductSubcategoryDto(
            subcategory.Id,
            subcategory.NameAr,
            subcategory.NameEn,
            subcategory.DescAr,
            subcategory.DescEn,
            subcategory.LogoId,
            logoUrl,
            subcategory.ProductCategoryId,
            category?.NameAr ?? "",
            category?.NameEn ?? "",
            0,
            subcategory.Created,
            subcategory.LastModified
        );

        return new CreateSubcategoryResponse(true, "Subcategory created successfully.", dto);
    }
}
