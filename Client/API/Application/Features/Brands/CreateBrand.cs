using Application.Common.Interfaces;
using Domain.Entities;
using FluentValidation;
using MediatR;

namespace Application.Features.Brands;

public record CreateBrandCommand(
    string NameEn,
    string NameAr,
    string? DescriptionEn,
    string? DescriptionAr,
    Guid? LogoId
) : IRequest<BrandDto>;

public class CreateBrandCommandValidator : AbstractValidator<CreateBrandCommand>
{
    public CreateBrandCommandValidator()
    {
        RuleFor(v => v.NameEn)
            .NotEmpty().WithMessage("English Name is required.")
            .MaximumLength(200);

        RuleFor(v => v.NameAr)
            .NotEmpty().WithMessage("Arabic Name is required.")
            .MaximumLength(200);
    }
}

public class CreateBrandCommandHandler : IRequestHandler<CreateBrandCommand, BrandDto>
{
    private readonly IApplicationDbContext _context;

    public CreateBrandCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<BrandDto> Handle(CreateBrandCommand request, CancellationToken cancellationToken)
    {
        var entity = new Brand
        {
            NameEn = request.NameEn,
            NameAr = request.NameAr,
            DescriptionEn = request.DescriptionEn,
            DescriptionAr = request.DescriptionAr,
            LogoId = request.LogoId
        };

        _context.Brands.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        // Fetch to include Logo URL if needed, or just return basic info
        // Optimizing for speed, assuming Logo URL is not immediately needed or handled by client via LogoId
        
        return new BrandDto(
            entity.Id,
            entity.NameEn,
            entity.NameAr,
            entity.DescriptionEn,
            entity.DescriptionAr,
            null // Logo URL retrieval handling might need refinement if immediately required
        );
    }
}
