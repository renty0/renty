using Application.Features.Returns;
using MediatR;

namespace Web.Endpoints;

public static class ReturnEndpoints
{
    public static void MapReturnEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/returns")
            .WithTags("Returns")
            .RequireAuthorization();

        group.MapGet("/", async (
            int pageNumber,
            int pageSize,
            DateOnly? startDate,
            DateOnly? endDate,
            long? productId,
            int? territoryId,
            ISender sender) =>
        {
            var result = await sender.Send(new GetReturnsQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                startDate,
                endDate,
                productId,
                territoryId
            ));
            return Results.Ok(result);
        })
        .WithName("GetReturns")
        .WithOpenApi();

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetReturnByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetReturnById")
        .WithOpenApi();

        group.MapPost("/", async (CreateReturnCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/returns/{result.Return!.Id}", result);
        })
        .WithName("CreateReturn")
        .WithOpenApi();

        group.MapPut("/{id:long}", async (long id, UpdateReturnCommand command, ISender sender) =>
        {
            if (id != command.Id)
            {
                return Results.BadRequest(new { Success = false, Message = "ID mismatch" });
            }
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("UpdateReturn")
        .WithOpenApi();

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteReturnCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteReturn")
        .WithOpenApi();

        // Analytics endpoint
        group.MapGet("/summary", async (
            DateOnly? startDate,
            DateOnly? endDate,
            int? territoryId,
            ISender sender) =>
        {
            var result = await sender.Send(new GetReturnsSummaryQuery(startDate, endDate, territoryId));
            return Results.Ok(result);
        })
        .WithName("GetReturnsSummary")
        .WithOpenApi();
    }
}
