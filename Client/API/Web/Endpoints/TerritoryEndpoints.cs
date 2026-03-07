using Application.Features.Territories;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class TerritoryEndpoints
{
    public static void MapTerritoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/territories").WithTags("Territories").RequireAuthorization();

        group.MapGet("/", async (string? continent, string? country, ISender sender) =>
            Api.Ok(await sender.Send(new GetTerritoriesQuery(continent, country))))
        .WithName("GetTerritories")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new GetTerritoryByIdQuery(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Not found", 404);
        })
        .WithName("GetTerritoryById")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateTerritoryCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            return r.Success ? Api.Created(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CreateTerritory")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPut("/{id:int}", async (int id, UpdateTerritoryCommand command, ISender sender) =>
        {
            if (id != command.Id) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateTerritory")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteTerritoryCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("DeleteTerritory")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}
