using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Territories;

public record DeleteTerritoryCommand(int Id) : IRequest<DeleteTerritoryResponse>;

public record DeleteTerritoryResponse(
    bool Success,
    string? Message
);

public class DeleteTerritoryCommandValidator : AbstractValidator<DeleteTerritoryCommand>
{
    public DeleteTerritoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid territory ID.");
    }
}

public class DeleteTerritoryCommandHandler : IRequestHandler<DeleteTerritoryCommand, DeleteTerritoryResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteTerritoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteTerritoryResponse> Handle(DeleteTerritoryCommand request, CancellationToken cancellationToken)
    {
        var territory = await _context.Territories
            .Include(t => t.Sales)
            .Include(t => t.Returns)
            .FirstOrDefaultAsync(t => t.Id == request.Id, cancellationToken);

        if (territory == null)
        {
            return new DeleteTerritoryResponse(false, "Territory not found.");
        }

        if (territory.Sales.Any())
        {
            return new DeleteTerritoryResponse(false, "Cannot delete territory with existing sales records.");
        }

        if (territory.Returns.Any())
        {
            return new DeleteTerritoryResponse(false, "Cannot delete territory with existing return records.");
        }

        _context.Territories.Remove(territory);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteTerritoryResponse(true, "Territory deleted successfully.");
    }
}
