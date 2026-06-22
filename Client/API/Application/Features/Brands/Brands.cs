using Application.Common.Interfaces;
using Application.Common;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace Application.Features.Brands;


public record BrandDto(int Id, string NameAr, string NameEn, string? DescAr, string? DescEn, Guid? LogoId, string? LogoUrl, int ItemCount);


public record GetBrandsQuery(string? Search, int Page, int Limit) : IRequest<GetBrandsResponse>;
public record GetBrandsResponse(List<BrandDto> Brands, int Total, int Page, int Pages);

public class GetBrandsQueryHandler : IRequestHandler<GetBrandsQuery, GetBrandsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetBrandsQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetBrandsResponse> Handle(GetBrandsQuery request, CancellationToken ct)
    {
        var query = _context.Brands.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(request.Search))
            query = query.Where(b => b.NameEn.Contains(request.Search) || b.NameAr.Contains(request.Search));

        var total = await query.CountAsync(ct);
        var brands = await query
            .OrderBy(b => b.NameEn)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(b => new { b.Id, b.NameAr, b.NameEn, b.DescAr, b.DescEn, b.LogoId, ItemCount = b.Items.Count, LogoPath = b.Logo != null ? b.Logo.StoragePath : null })
            .ToListAsync(ct);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;

        var brandDtos = brands.Select(b => {
             string? logoUrl = b.LogoPath.ToAbsoluteUrl(baseUrl);
             return new BrandDto(b.Id, b.NameAr, b.NameEn, b.DescAr, b.DescEn, b.LogoId, logoUrl, b.ItemCount);
        }).ToList();

        return new GetBrandsResponse(brandDtos, total, request.Page,
            (int)Math.Ceiling((double)total / request.Limit));
    }
}


public record GetBrandByIdQuery(int Id) : IRequest<GetBrandByIdResponse>;
public record GetBrandByIdResponse(bool Found, string? Error, BrandDto? Brand);

public class GetBrandByIdQueryHandler : IRequestHandler<GetBrandByIdQuery, GetBrandByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public GetBrandByIdQueryHandler(IApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GetBrandByIdResponse> Handle(GetBrandByIdQuery request, CancellationToken ct)
    {
        var b = await _context.Brands.AsNoTracking()
            .Where(x => x.Id == request.Id)
            .Select(b => new { b.Id, b.NameAr, b.NameEn, b.DescAr, b.DescEn, b.LogoId, ItemCount = b.Items.Count, LogoPath = b.Logo != null ? b.Logo.StoragePath : null })
            .FirstOrDefaultAsync(ct);

        if (b is null) return new GetBrandByIdResponse(false, "Brand not found.", null);

        var requestUrl = _httpContextAccessor.HttpContext?.Request;
        var baseUrl = requestUrl != null ? $"{requestUrl.Scheme}://{requestUrl.Host}" : string.Empty;

        string? logoUrl = b.LogoPath.ToAbsoluteUrl(baseUrl);

        var dto = new BrandDto(b.Id, b.NameAr, b.NameEn, b.DescAr, b.DescEn, b.LogoId, logoUrl, b.ItemCount);
        return new GetBrandByIdResponse(true, null, dto);
    }
}


public record CreateBrandCommand(string NameAr, string NameEn, string? DescAr, string? DescEn, Guid? LogoId) : IRequest<CreateBrandResponse>;
public record CreateBrandResponse(bool Success, string? Error, BrandDto? Brand);

public class CreateBrandCommandValidator : AbstractValidator<CreateBrandCommand>
{
    public CreateBrandCommandValidator()
    {
        RuleFor(x => x.NameEn).NotEmpty().MaximumLength(100);
        RuleFor(x => x.NameAr).NotEmpty().MaximumLength(100);
    }
}

public class CreateBrandCommandHandler : IRequestHandler<CreateBrandCommand, CreateBrandResponse>
{
    private readonly IApplicationDbContext _context;
    public CreateBrandCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<CreateBrandResponse> Handle(CreateBrandCommand request, CancellationToken ct)
    {
        if (await _context.Brands.AnyAsync(b => b.NameEn == request.NameEn, ct))
            return new CreateBrandResponse(false, "Brand name already exists.", null);

        var brand = new Brand { 
            NameAr = request.NameAr ?? string.Empty, 
            NameEn = request.NameEn ?? string.Empty, 
            DescAr = request.DescAr, 
            DescEn = request.DescEn, 
            LogoId = request.LogoId 
        };
        _context.Brands.Add(brand);
        await _context.SaveChangesAsync(ct);

        return new CreateBrandResponse(true, null, new BrandDto(brand.Id, brand.NameAr, brand.NameEn, brand.DescAr, brand.DescEn, brand.LogoId, null, 0));
    }
}


public record UpdateBrandCommand(int Id, string NameAr, string NameEn, string? DescAr, string? DescEn, Guid? LogoId) : IRequest<UpdateBrandResponse>;
public record UpdateBrandResponse(bool Success, string? Error, BrandDto? Brand);

public class UpdateBrandCommandHandler : IRequestHandler<UpdateBrandCommand, UpdateBrandResponse>
{
    private readonly IApplicationDbContext _context;
    public UpdateBrandCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<UpdateBrandResponse> Handle(UpdateBrandCommand request, CancellationToken ct)
    {
        var brand = await _context.Brands.FirstOrDefaultAsync(b => b.Id == request.Id, ct);
        if (brand is null) return new UpdateBrandResponse(false, "Brand not found.", null);

        brand.NameAr = request.NameAr ?? string.Empty;
        brand.NameEn = request.NameEn ?? string.Empty;
        brand.DescAr = request.DescAr;
        brand.DescEn = request.DescEn;
        brand.LogoId = request.LogoId;
        await _context.SaveChangesAsync(ct);

        return new UpdateBrandResponse(true, null, new BrandDto(brand.Id, brand.NameAr, brand.NameEn, brand.DescAr, brand.DescEn, brand.LogoId, null, 0));
    }
}


public record DeleteBrandCommand(int Id) : IRequest<DeleteBrandResponse>;
public record DeleteBrandResponse(bool Success, string? Error);

public class DeleteBrandCommandHandler : IRequestHandler<DeleteBrandCommand, DeleteBrandResponse>
{
    private readonly IApplicationDbContext _context;
    public DeleteBrandCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<DeleteBrandResponse> Handle(DeleteBrandCommand request, CancellationToken ct)
    {
        var brand = await _context.Brands.FirstOrDefaultAsync(b => b.Id == request.Id, ct);
        if (brand is null) return new DeleteBrandResponse(false, "Brand not found.");

        _context.Brands.Remove(brand);
        await _context.SaveChangesAsync(ct);
        return new DeleteBrandResponse(true, null);
    }
}
