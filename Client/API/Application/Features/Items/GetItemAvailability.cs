using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Items;

public record BookedRangeDto(DateTime Start, DateTime End);

public record GetItemAvailabilityQuery(Guid ItemId) : IRequest<List<BookedRangeDto>>;

public class GetItemAvailabilityQueryHandler : IRequestHandler<GetItemAvailabilityQuery, List<BookedRangeDto>>
{
    private readonly IApplicationDbContext _context;

    public GetItemAvailabilityQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<BookedRangeDto>> Handle(GetItemAvailabilityQuery request, CancellationToken ct)
    {
        var bookedDates = await _context.Rentals
            .Where(r => r.ItemId == request.ItemId &&
                        r.Status != RentalStatus.Cancelled &&
                        r.Status != RentalStatus.Rejected &&
                        r.EndDate >= DateTime.UtcNow)
            .Select(r => new BookedRangeDto(r.StartDate, r.EndDate))
            .ToListAsync(ct);

        return bookedDates;
    }
}
