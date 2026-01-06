using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Products;

public record DeleteProductCommand(long Id) : IRequest<DeleteProductResponse>;

public record DeleteProductResponse(
    bool Success,
    string? Message
);

public class DeleteProductCommandValidator : AbstractValidator<DeleteProductCommand>
{
    public DeleteProductCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid product ID.");
    }
}

public class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand, DeleteProductResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteProductCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteProductResponse> Handle(DeleteProductCommand request, CancellationToken cancellationToken)
    {
        var product = await _context.Products
            .Include(p => p.Sales)
            .Include(p => p.Returns)
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (product == null)
        {
            return new DeleteProductResponse(false, "Product not found.");
        }

        if (product.Sales.Any())
        {
            return new DeleteProductResponse(false, "Cannot delete product with existing sales records.");
        }

        if (product.Returns.Any())
        {
            return new DeleteProductResponse(false, "Cannot delete product with existing return records.");
        }

        _context.Products.Remove(product);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteProductResponse(true, "Product deleted successfully.");
    }
}
