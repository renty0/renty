using Application.Features.Territories;
using MediatR;

namespace Web.Endpoints;

public static class TerritoryEndpoints
{
    public static void MapTerritoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/territories")
            .WithTags("Territories")
            .RequireAuthorization();

        group.MapGet("/", async (string? continent, string? country, ISender sender) =>
        {
            var result = await sender.Send(new GetTerritoriesQuery(continent, country));
            return Results.Ok(result);
        })
        .WithName("GetTerritories")
        .WithOpenApi();

        group.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new GetTerritoryByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetTerritoryById")
        .WithOpenApi();

        group.MapPost("/", async (CreateTerritoryCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/territories/{result.Territory!.Id}", result);
        })
        .WithName("CreateTerritory")
        .WithOpenApi();

        group.MapPut("/{id:int}", async (int id, UpdateTerritoryCommand command, ISender sender) =>
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
        .WithName("UpdateTerritory")
        .WithOpenApi();

        group.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteTerritoryCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteTerritory")
        .WithOpenApi();
    }
}
