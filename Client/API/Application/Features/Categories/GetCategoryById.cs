using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record GetCategoryByIdQuery(int Id) : IRequest<ProductCategoryDto?>;

public class GetCategoryByIdQueryHandler : IRequestHandler<GetCategoryByIdQuery, ProductCategoryDto?>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetCategoryByIdQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<ProductCategoryDto?> Handle(GetCategoryByIdQuery request, CancellationToken cancellationToken)
    {
        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;

        var category = await _context.ProductCategories
            .AsNoTracking()
            .Where(c => c.Id == request.Id)
            .Select(c => new
            {
                c.Id,
                c.NameAr,
                c.NameEn,
                c.DescAr,
                c.DescEn,
                c.LogoId,
                LogoStoragePath = c.Logo != null ? c.Logo.StoragePath : null,
                SubcategoryCount = c.Subcategories.Count,
                c.Created,
                c.LastModified
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (category == null) return null;

        return new ProductCategoryDto(
            category.Id,
            category.NameAr,
            category.NameEn,
            category.DescAr,
            category.DescEn,
            category.LogoId,
            !string.IsNullOrEmpty(category.LogoStoragePath) 
                ? $"{baseUrl.TrimEnd('/')}/{category.LogoStoragePath.Replace("\\", "/").TrimStart('/')}" 
                : null,
            category.SubcategoryCount,
            category.Created,
            category.LastModified
        );
    }
}
