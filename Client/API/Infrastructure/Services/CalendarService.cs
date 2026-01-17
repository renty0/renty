using System.Globalization;
using Application.Common.Interfaces;
using Microsoft.EntityFrameworkCore;
using CalendarEntity = Domain.Entities.Calendar;

namespace Infrastructure.Services;

public class CalendarService : ICalendarService
{
    private readonly IApplicationDbContext _context;

    public CalendarService(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task SeedCalendarAsync(int startYear, int endYear, CancellationToken cancellationToken = default)
    {
        var existingDates = await _context.Calendars
            .Select(c => c.Date)
            .ToHashSetAsync(cancellationToken);

        var calendarsToAdd = new List<CalendarEntity>();
        var culture = CultureInfo.InvariantCulture;

        for (int year = startYear; year <= endYear; year++)
        {
            var startDate = new DateOnly(year, 1, 1);
            var endDate = new DateOnly(year, 12, 31);

            for (var date = startDate; date <= endDate; date = date.AddDays(1))
            {
                if (existingDates.Contains(date))
                    continue;

                var calendarEntry = new CalendarEntity
                {
                    Date = date,
                    DayName = date.DayOfWeek.ToString(),
                    StartOfWeek = GetStartOfWeek(date),
                    StartOfMonth = new DateOnly(date.Year, date.Month, 1),
                    StartOfQuarter = GetStartOfQuarter(date),
                    MonthName = culture.DateTimeFormat.GetMonthName(date.Month),
                    Month = date.Month,
                    StartOfYear = new DateOnly(date.Year, 1, 1),
                    Year = date.Year,
                    Quarter = (date.Month - 1) / 3 + 1,
                    DayOfWeek = (int)date.DayOfWeek,
                    DayOfMonth = date.Day,
                    DayOfYear = date.DayOfYear,
                    WeekOfYear = GetWeekOfYear(date),
                    IsWeekend = date.DayOfWeek == System.DayOfWeek.Saturday || date.DayOfWeek == System.DayOfWeek.Sunday
                };

                calendarsToAdd.Add(calendarEntry);
            }
        }

        if (calendarsToAdd.Count > 0)
        {
            await _context.Calendars.AddRangeAsync(calendarsToAdd, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    private static DateOnly GetStartOfWeek(DateOnly date)
    {
        int diff = (7 + (date.DayOfWeek - DayOfWeek.Monday)) % 7;
        return date.AddDays(-diff);
    }

    private static DateOnly GetStartOfQuarter(DateOnly date)
    {
        int quarterMonth = ((date.Month - 1) / 3) * 3 + 1;
        return new DateOnly(date.Year, quarterMonth, 1);
    }

    private static int GetWeekOfYear(DateOnly date)
    {
        var culture = CultureInfo.InvariantCulture;
        var calendar = culture.Calendar;
        return calendar.GetWeekOfYear(
            date.ToDateTime(TimeOnly.MinValue),
            CalendarWeekRule.FirstFourDayWeek,
            DayOfWeek.Monday
        );
    }
}
