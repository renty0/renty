using Application.Features.Calendar;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class CalendarEndpoints
{
    public static void MapCalendarEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/calendar").WithTags("Calendar").RequireAuthorization();

        group.MapGet("/", async (int? year, int? month, ISender sender) =>
        {
            var result = await sender.Send(new GetCalendarDatesQuery(year, month));
            return Api.Ok(result);
        })
        .WithName("GetCalendarDates")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapPost("/seed", async (SeedCalendarCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Seed failed");
        })
        .WithName("SeedCalendar")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}
