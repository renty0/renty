using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Calendar;

public record GetCalendarDatesQuery(
    int? Year = null,
    int? Month = null
) : IRequest<GetCalendarDatesResponse>;

public record GetCalendarDatesResponse(
    bool Success,
    string? Message,
    List<CalendarDto> Dates
);

public class GetCalendarDatesQueryHandler : IRequestHandler<GetCalendarDatesQuery, GetCalendarDatesResponse>
{
    private readonly IApplicationDbContext _context;

    public GetCalendarDatesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GetCalendarDatesResponse> Handle(GetCalendarDatesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Calendars.AsQueryable();

        if (request.Year.HasValue)
        {
            query = query.Where(c => c.Year == request.Year.Value);
        }

        if (request.Month.HasValue)
        {
            query = query.Where(c => c.Month == request.Month.Value);
        }

        var dates = await query
            .OrderBy(c => c.Date)
            .Select(c => new CalendarDto(
                c.Date,
                c.DayName,
                c.MonthName,
                c.Month,
                c.Year,
                c.Quarter,
                c.IsWeekend
            ))
            .ToListAsync(cancellationToken);

        return new GetCalendarDatesResponse(true, null, dates);
    }
}
