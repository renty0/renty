using Application.Features.Seeding;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Web.Responses;

namespace Web.Endpoints;

public static class SeedingEndpoints
{
    public static void MapSeedingEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/seeding").WithTags("Seeding");

        group.MapPost("/from-excel", async (ISender sender, [FromBody] SeedRequest request) =>
        {
            var result = await sender.Send(new SeedFromExcelCommand(request.FilePath));
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Seed failed");
        })
        .WithName("SeedFromExcel")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}

public record SeedRequest(string FilePath);
