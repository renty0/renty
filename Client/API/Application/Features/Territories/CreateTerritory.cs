using Application.Common.Interfaces;
using Application.Common.Models;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Territories;

public record CreateTerritoryCommand(
    string Region,
    string Country,
    string Continent
) : IRequest<CreateTerritoryResponse>;

public record CreateTerritoryResponse(
    bool Success,
    string? Message,
    TerritoryDto? Territory
);

public class CreateTerritoryCommandValidator : AbstractValidator<CreateTerritoryCommand>
{
    public CreateTerritoryCommandValidator()
    {
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

public class CreateTerritoryCommandHandler : IRequestHandler<CreateTerritoryCommand, CreateTerritoryResponse>
{
    private readonly IApplicationDbContext _context;

    public CreateTerritoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<CreateTerritoryResponse> Handle(CreateTerritoryCommand request, CancellationToken cancellationToken)
    {
        var exists = await _context.Territories
            .AnyAsync(t =>
                t.Region == request.Region &&
                t.Country == request.Country &&
                t.Continent == request.Continent,
                cancellationToken);

        if (exists)
        {
            return new CreateTerritoryResponse(false, "This territory already exists.", null);
        }

        var territory = new Territory
        {
            Region = request.Region,
            Country = request.Country,
            Continent = request.Continent
        };

        _context.Territories.Add(territory);
        await _context.SaveChangesAsync(cancellationToken);

        var dto = new TerritoryDto(
            territory.Id,
            territory.Region,
            territory.Country,
            territory.Continent
        );

        return new CreateTerritoryResponse(true, "Territory created successfully.", dto);
    }
}
