using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Admin;

public record ApprovalHistoryDto(
    string Type,
    string Target,
    string Decision,
    string ProcessedBy,
    DateTime ProcessedAt,
    string? Reason
);

public record GetApprovalHistoryQuery() : IRequest<List<ApprovalHistoryDto>>;

public class GetApprovalHistoryQueryHandler : IRequestHandler<GetApprovalHistoryQuery, List<ApprovalHistoryDto>>
{
    private readonly IApplicationDbContext _context;

    public GetApprovalHistoryQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<ApprovalHistoryDto>> Handle(GetApprovalHistoryQuery request, CancellationToken ct)
    {
        var history = new List<ApprovalHistoryDto>();

        // Get recent ID Verifications
        var idVerifications = await _context.IdVerifications
            .Include(v => v.User)
            .Include(v => v.ReviewedBy)
            .Where(v => v.Status == VerificationStatus.Approved || v.Status == VerificationStatus.Rejected)
            .OrderByDescending(v => v.ReviewedAt)
            .Take(50)
            .ToListAsync(ct);

        foreach (var v in idVerifications)
        {
            history.Add(new ApprovalHistoryDto(
                "ID",
                v.User.FirstName + " " + v.User.LastName,
                v.Status.ToString(),
                v.ReviewedBy?.FirstName + " " + v.ReviewedBy?.LastName ?? "System",
                v.ReviewedAt?.UtcDateTime ?? v.CreatedAt.UtcDateTime,
                v.RejectionReason
            ));
        }

        // Get recently reviewed Items
        var items = await _context.Items
            .Include(i => i.Owner)
            .Where(i => i.Status == NewItemStatus.Available || i.Status == NewItemStatus.Suspended)
            .OrderByDescending(i => i.UpdatedAt)
            .Take(50)
            .ToListAsync(ct);

        foreach (var i in items)
        {
            history.Add(new ApprovalHistoryDto(
                "Item",
                i.TitleEn,
                i.Status == NewItemStatus.Available ? "Approved" : "Rejected",
                "Admin Team",
                i.UpdatedAt,
                i.AdminNote
            ));
        }

        // Return history sorted by date
        return history.OrderByDescending(h => h.ProcessedAt).Take(100).ToList();
    }
}
