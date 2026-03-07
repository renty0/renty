using Application.Common.Interfaces;
using Application.Common.Models;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Territories;

public record UpdateTerritoryCommand(
    int Id,
    string Region,
    string Country,
    string Continent
) : IRequest<UpdateTerritoryResponse>;

public record UpdateTerritoryResponse(
    bool Success,
    string? Message,
    TerritoryDto? Territory
);

public class UpdateTerritoryCommandValidator : AbstractValidator<UpdateTerritoryCommand>
{
    public UpdateTerritoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid territory ID.");

        RuleFor(x => x.Region)
            .NotEmpty().WithMessage("Region is required.")
            .MaximumLength(100).WithMessage("Region must not exceed 100 characters.");

        RuleFor(x => x.Country)
            .NotEmpty().WithMessage("Country is required.")
            .MaximumLength(100).WithMessage("Country must not exceed 100 characters.");

        RuleFor(x => x.Continent)
            .NotEmpty().WithMessage("Continent is required.")
            .MaximumLength(100).WithMessage("Continent must not exceed 100 characters.");
    }
}

public class UpdateTerritoryCommandHandler : IRequestHandler<UpdateTerritoryCommand, UpdateTerritoryResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateTerritoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UpdateTerritoryResponse> Handle(UpdateTerritoryCommand request, CancellationToken cancellationToken)
    {
        var territory = await _context.Territories
            .FirstOrDefaultAsync(t => t.Id == request.Id, cancellationToken);

        if (territory == null)
        {
            return new UpdateTerritoryResponse(false, "Territory not found.", null);
        }

        territory.Region = request.Region;
        territory.Country = request.Country;
        territory.Continent = request.Continent;

        await _context.SaveChangesAsync(cancellationToken);

        var dto = new TerritoryDto(
            territory.Id,
            territory.Region,
            territory.Country,
            territory.Continent
        );

        return new UpdateTerritoryResponse(true, "Territory updated successfully.", dto);
    }
}
