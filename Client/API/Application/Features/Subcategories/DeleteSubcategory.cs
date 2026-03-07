using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Subcategories;

public record DeleteSubcategoryCommand(int Id) : IRequest<DeleteSubcategoryResponse>;

public record DeleteSubcategoryResponse(
    bool Success,
    string? Message
);

public class DeleteSubcategoryCommandValidator : AbstractValidator<DeleteSubcategoryCommand>
{
    public DeleteSubcategoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid subcategory ID.");
    }
}

public class DeleteSubcategoryCommandHandler : IRequestHandler<DeleteSubcategoryCommand, DeleteSubcategoryResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteSubcategoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteSubcategoryResponse> Handle(DeleteSubcategoryCommand request, CancellationToken cancellationToken)
    {
        var subcategory = await _context.ProductSubcategories
            .Include(s => s.Products)
            .FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);

        if (subcategory == null)
        {
            return new DeleteSubcategoryResponse(false, "Subcategory not found.");
        }

        if (subcategory.Products.Any())
        {
            return new DeleteSubcategoryResponse(false, "Cannot delete subcategory with existing products.");
        }

        _context.ProductSubcategories.Remove(subcategory);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteSubcategoryResponse(true, "Subcategory deleted successfully.");
    }
}
