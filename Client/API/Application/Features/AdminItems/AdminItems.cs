using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.AdminItems;

// ── REVIEW ITEM ───────────────────────────────────────────────────────────────

public record ReviewItemCommand(Guid ItemId, string Status, string? RejectionReason) : IRequest<ReviewItemResponse>;
public record ReviewItemResponse(bool Success, string? Error);

public class ReviewItemCommandHandler : IRequestHandler<ReviewItemCommand, ReviewItemResponse>
{
    private readonly IApplicationDbContext _context;

    public ReviewItemCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<ReviewItemResponse> Handle(ReviewItemCommand request, CancellationToken ct)
    {
        var item = await _context.Items.FirstOrDefaultAsync(i => i.Id == request.ItemId, ct);
        if (item == null) return new ReviewItemResponse(false, "Item not found.");

        if (request.Status == "approved")
        {
            item.Status = NewItemStatus.Available;
        }
        else if (request.Status == "rejected")
        {
            item.Status = NewItemStatus.Suspended;
            // Optionally store the reason somewhere like a ItemReviews or push a notification.
        }
        else
        {
            return new ReviewItemResponse(false, "Status must be 'approved' or 'rejected'.");
        }

        await _context.SaveChangesAsync(ct);
        return new ReviewItemResponse(true, null);
    }
}
