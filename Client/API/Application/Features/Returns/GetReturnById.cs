using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Returns;

public record GetReturnByIdQuery(long Id) : IRequest<GetReturnByIdResponse>;

public record GetReturnByIdResponse(
    bool Success,
    string? Message,
    ReturnDto? Return
);

public class GetReturnByIdQueryHandler : IRequestHandler<GetReturnByIdQuery, GetReturnByIdResponse>
{
    private readonly IApplicationDbContext _context;

    public GetReturnByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetReturnByIdResponse> Handle(GetReturnByIdQuery request, CancellationToken cancellationToken)
    {
        var returnItem = await _context.Returns
            .Include(r => r.Product)
            .Include(r => r.Territory)
            .Where(r => r.Id == request.Id)
            .Select(r => new ReturnDto(
                r.Id,
                r.ReturnDate,
                r.ReturnQuantity,
                r.ReturnReason,
                r.ProductId,
                r.Product.ProductName,
                r.TerritoryId,
                r.Territory.Region,
                r.Territory.Country,
                r.ReturnQuantity * (r.Product.DiscountPrice ?? r.Product.ProductPrice)
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (returnItem == null)
        {
            return new GetReturnByIdResponse(false, "Return not found.", null);
        }

        return new GetReturnByIdResponse(true, null, returnItem);
    }
}
