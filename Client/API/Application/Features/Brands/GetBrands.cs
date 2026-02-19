using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Brands;

public record GetBrandsQuery(
    string? SearchTerm = null
) : IRequest<List<BrandDto>>;

public class GetBrandsQueryHandler : IRequestHandler<GetBrandsQuery, List<BrandDto>>
{
    private readonly IApplicationDbContext _context;

    public GetBrandsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<BrandDto>> Handle(GetBrandsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Brands.AsQueryable();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var term = request.SearchTerm.ToLower();
            query = query.Where(b => 
                b.NameEn.ToLower().Contains(term) || 
                b.NameAr.ToLower().Contains(term));
        }

        return await query
            .OrderBy(b => b.NameEn)
            .Select(b => new BrandDto(
                b.Id,
                b.NameEn,
                b.NameAr,
                b.DescriptionEn,
                b.DescriptionAr,
                b.Logo != null ? b.Logo.StoragePath : null
            ))
            .ToListAsync(cancellationToken);
    }
}
