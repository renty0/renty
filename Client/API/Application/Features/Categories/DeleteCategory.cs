using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Categories;

public record DeleteCategoryCommand(int Id) : IRequest<DeleteCategoryResponse>;

public record DeleteCategoryResponse(
    bool Success,
    string? Message
);

public class DeleteCategoryCommandValidator : AbstractValidator<DeleteCategoryCommand>
{
    public DeleteCategoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid category ID.");
    }
}

public class DeleteCategoryCommandHandler : IRequestHandler<DeleteCategoryCommand, DeleteCategoryResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteCategoryCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteCategoryResponse> Handle(DeleteCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _context.ProductCategories
            .Include(c => c.Subcategories)
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);

        if (category == null)
        {
            return new DeleteCategoryResponse(false, "Category not found.");
        }

        if (category.Subcategories.Any())
        {
            return new DeleteCategoryResponse(false, "Cannot delete category with existing subcategories.");
        }

        _context.ProductCategories.Remove(category);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteCategoryResponse(true, "Category deleted successfully.");
    }
}
