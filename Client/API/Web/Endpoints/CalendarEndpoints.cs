using Application.Features.Calendar;
using MediatR;

namespace Web.Endpoints;

public static class CalendarEndpoints
{
    public static void MapCalendarEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/calendar")
            .WithTags("Calendar")
            .RequireAuthorization();

        group.MapGet("/", async (int? year, int? month, ISender sender) =>
        {
            var result = await sender.Send(new GetCalendarDatesQuery(year, month));
            return Results.Ok(result);
        })
        .WithName("GetCalendarDates")
        .WithOpenApi();

        group.MapPost("/seed", async (SeedCalendarCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("SeedCalendar")
        .WithOpenApi();
    }
}
