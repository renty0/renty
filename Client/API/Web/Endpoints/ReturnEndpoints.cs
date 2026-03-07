using Application.Features.Returns;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class ReturnEndpoints
{
    public static void MapReturnEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/returns").WithTags("Returns").RequireAuthorization();

        group.MapGet("/", async (int pageNumber, int pageSize, DateOnly? startDate, DateOnly? endDate,
            long? productId, int? territoryId, ISender sender) =>
            Api.Ok(await sender.Send(new GetReturnsQuery(
                pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10,
                startDate, endDate, productId, territoryId))))
        .WithName("GetReturns")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new GetReturnByIdQuery(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Not found", 404);
        })
        .WithName("GetReturnById")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateReturnCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            return r.Success ? Api.Created(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CreateReturn")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPut("/{id:long}", async (long id, UpdateReturnCommand command, ISender sender) =>
        {
            if (id != command.Id) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateReturn")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteReturnCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("DeleteReturn")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapGet("/summary", async (DateOnly? startDate, DateOnly? endDate, int? territoryId, ISender sender) =>
            Api.Ok(await sender.Send(new GetReturnsSummaryQuery(startDate, endDate, territoryId))))
        .WithName("GetReturnsSummary")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);
    }
}
