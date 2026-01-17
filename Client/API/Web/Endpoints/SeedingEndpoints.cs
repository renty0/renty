using Application.Features.Seeding;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Web.Endpoints;

public static class SeedingEndpoints
{
    public static void MapSeedingEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/seeding")
            .WithTags("Seeding");
            //.RequireAuthorization(new AuthorizeAttribute { Roles = "SuperAdmin" });

        group.MapPost("/from-excel", async (ISender sender, [FromBody] SeedRequest request) =>
        {
            var command = new SeedFromExcelCommand(request.FilePath);
            var result = await sender.Send(command);

            if (result.Success)
            {
                return Results.Ok(result);
            }

            return Results.BadRequest(result);
        })
        .WithName("SeedFromExcel")
        .WithOpenApi();
    }
}

public record SeedRequest(string FilePath);
