namespace Application.Common.Interfaces;

public interface ICalendarService
{
    Task SeedCalendarAsync(int startYear, int endYear, CancellationToken cancellationToken = default);
}
