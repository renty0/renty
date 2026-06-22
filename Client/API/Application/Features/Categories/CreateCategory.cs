using Application.Common.Interfaces;
using Application.Common.Models;
using Application.Common;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record CreateCategoryCommand(string NameAr, string NameEn, string? DescAr, string? DescEn, Guid? LogoId) : IRequest<CreateCategoryResponse>;

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
            .NotEmpty().WithMessage("Category English name is required.")
            .MaximumLength(100).WithMessage("Category English name must not exceed 100 characters.");
        
        RuleFor(x => x.NameAr)
            .NotEmpty().WithMessage("Category Arabic name is required.")
            .MaximumLength(100).WithMessage("Category Arabic name must not exceed 100 characters.");
            
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

        if (request.LogoId.HasValue)
        {
            var logoExists = await _context.MediaFiles.AnyAsync(m => m.Id == request.LogoId, cancellationToken);
            if (!logoExists)
            {
                return new CreateCategoryResponse(false, "The specified logo image does not exist.", null);
            }
        }

        var category = new ProductCategory
        {
            NameAr = request.NameAr ?? string.Empty,
            NameEn = request.NameEn ?? string.Empty,
            DescAr = request.DescAr,
            DescEn = request.DescEn,
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
                logoUrl = logo.StoragePath.ToAbsoluteUrl(baseUrl);
            }
        }

        var dto = new ProductCategoryDto(category.Id, category.NameAr, category.NameEn, category.DescAr, category.DescEn, category.LogoId, logoUrl, 0, category.Created, category.LastModified);
        return new CreateCategoryResponse(true, "Category created successfully.", dto);
    }
}
