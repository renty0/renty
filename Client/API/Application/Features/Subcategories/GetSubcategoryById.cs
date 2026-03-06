using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

using Microsoft.AspNetCore.Http;

namespace Application.Features.Subcategories;

public record GetSubcategoryByIdQuery(int Id) : IRequest<GetSubcategoryByIdResponse>;

public record GetSubcategoryByIdResponse(
    bool Success,
    string? Message,
    ProductSubcategoryDto? Subcategory
);

public class GetSubcategoryByIdQueryHandler : IRequestHandler<GetSubcategoryByIdQuery, GetSubcategoryByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetSubcategoryByIdQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetSubcategoryByIdResponse> Handle(GetSubcategoryByIdQuery request, CancellationToken cancellationToken)
    {
        var item = await _context.ProductSubcategories
            .Include(s => s.Category)
            .Include(s => s.Products)
            .Include(s => s.Logo)
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);

        if (item == null)
        {
            return new GetSubcategoryByIdResponse(false, "Subcategory not found.", null);
        }

        string? logoUrl = null;
        if (item.Logo != null)
        {
            var requestUrl = _httpContextAccessor.HttpContext?.Request;
            var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;
            logoUrl = $"{baseUrl.TrimEnd('/')}/{item.Logo.StoragePath.Replace("\\", "/").TrimStart('/')}";
        }

        var dto = new ProductSubcategoryDto(
            item.Id,
            item.NameAr,
            item.NameEn,
            item.DescAr,
            item.DescEn,
            item.LogoId,
            logoUrl,
            item.ProductCategoryId,
            item.Category?.NameAr ?? "",
            item.Category?.NameEn ?? "",
            item.Products.Count,
            item.Created,
            item.LastModified
        );

        return new GetSubcategoryByIdResponse(true, null, dto);
    }
}
