using Application.Common.Interfaces;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Brands;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record BrandDto(int Id, string Name, string? Description, string? LogoUrl, int ItemCount);

// ── GET ALL ───────────────────────────────────────────────────────────────────

public record GetBrandsQuery(string? Search, int Page, int Limit) : IRequest<GetBrandsResponse>;
public record GetBrandsResponse(List<BrandDto> Brands, int Total, int Page, int Pages);

public class GetBrandsQueryHandler : IRequestHandler<GetBrandsQuery, GetBrandsResponse>
{
    private readonly IApplicationDbContext _context;
    public GetBrandsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetBrandsResponse> Handle(GetBrandsQuery request, CancellationToken ct)
    {
        var query = _context.Brands.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(request.Search))
            query = query.Where(b => b.Name.Contains(request.Search));

        var total = await query.CountAsync(ct);
        var brands = await query
            .OrderBy(b => b.Name)
            .Skip((request.Page - 1) * request.Limit)
            .Take(request.Limit)
            .Select(b => new BrandDto(b.Id, b.Name, b.Description, b.LogoUrl, b.Items.Count))
            .ToListAsync(ct);

        return new GetBrandsResponse(brands, total, request.Page,
            (int)Math.Ceiling((double)total / request.Limit));
    }
}

// ── GET BY ID ─────────────────────────────────────────────────────────────────

public record GetBrandByIdQuery(int Id) : IRequest<GetBrandByIdResponse>;
public record GetBrandByIdResponse(bool Found, string? Error, BrandDto? Brand);

public class GetBrandByIdQueryHandler : IRequestHandler<GetBrandByIdQuery, GetBrandByIdResponse>
{
    private readonly IApplicationDbContext _context;
    public GetBrandByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetBrandByIdResponse> Handle(GetBrandByIdQuery request, CancellationToken ct)
    {
        var b = await _context.Brands.AsNoTracking()
            .Where(x => x.Id == request.Id)
            .Select(b => new BrandDto(b.Id, b.Name, b.Description, b.LogoUrl, b.Items.Count))
            .FirstOrDefaultAsync(ct);

        return b is null
            ? new GetBrandByIdResponse(false, "Brand not found.", null)
            : new GetBrandByIdResponse(true, null, b);
    }
}

// ── CREATE ────────────────────────────────────────────────────────────────────

public record CreateBrandCommand(string Name, string? Description, string? LogoUrl) : IRequest<CreateBrandResponse>;
public record CreateBrandResponse(bool Success, string? Error, BrandDto? Brand);

public class CreateBrandCommandValidator : AbstractValidator<CreateBrandCommand>
{
    public CreateBrandCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
    }
}

public class CreateBrandCommandHandler : IRequestHandler<CreateBrandCommand, CreateBrandResponse>
{
    private readonly IApplicationDbContext _context;
    public CreateBrandCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<CreateBrandResponse> Handle(CreateBrandCommand request, CancellationToken ct)
    {
        if (await _context.Brands.AnyAsync(b => b.Name == request.Name, ct))
            return new CreateBrandResponse(false, "Brand name already exists.", null);

        var brand = new Brand { Name = request.Name, Description = request.Description, LogoUrl = request.LogoUrl };
        _context.Brands.Add(brand);
        await _context.SaveChangesAsync(ct);

        return new CreateBrandResponse(true, null, new BrandDto(brand.Id, brand.Name, brand.Description, brand.LogoUrl, 0));
    }
}

// ── UPDATE ────────────────────────────────────────────────────────────────────

public record UpdateBrandCommand(int Id, string Name, string? Description, string? LogoUrl) : IRequest<UpdateBrandResponse>;
public record UpdateBrandResponse(bool Success, string? Error, BrandDto? Brand);

public class UpdateBrandCommandHandler : IRequestHandler<UpdateBrandCommand, UpdateBrandResponse>
{
    private readonly IApplicationDbContext _context;
    public UpdateBrandCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<UpdateBrandResponse> Handle(UpdateBrandCommand request, CancellationToken ct)
    {
        var brand = await _context.Brands.FirstOrDefaultAsync(b => b.Id == request.Id, ct);
        if (brand is null) return new UpdateBrandResponse(false, "Brand not found.", null);

        brand.Name = request.Name;
        brand.Description = request.Description;
        brand.LogoUrl = request.LogoUrl;
        await _context.SaveChangesAsync(ct);

        return new UpdateBrandResponse(true, null, new BrandDto(brand.Id, brand.Name, brand.Description, brand.LogoUrl, 0));
    }
}

// ── DELETE ────────────────────────────────────────────────────────────────────

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
