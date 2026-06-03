using Application.Features.RentRequests;
using Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class RentRequestEndpoints
{
    public static void MapRentRequestEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/rent-requests").WithTags("Rent Requests").RequireAuthorization();

        group.MapGet("/my-requests", async (int pageNumber, int pageSize, RentRequestStatus? status, ISender sender) =>
            Api.Ok(await sender.Send(new GetRentRequestsQuery(pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10, status, false))))
        .WithName("GetMyRentRequests")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/received", async (int pageNumber, int pageSize, RentRequestStatus? status, ISender sender) =>
            Api.Ok(await sender.Send(new GetRentRequestsQuery(pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10, status, true))))
        .WithName("GetReceivedRentRequests")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new GetRentRequestByIdQuery(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Not found", 404);
        })
        .WithName("GetRentRequestById")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateRentRequestCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            return r.Success ? Api.Created(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CreateRentRequest")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPost("/{id:long}/respond", async (long id, RespondToRentRequestCommand command, ISender sender) =>
        {
            if (id != command.RequestId) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("RespondToRentRequest")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPost("/{id:long}/cancel", async (long id, CancelRentRequestCommand command, ISender sender) =>
        {
            if (id != command.RequestId) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CancelRentRequest")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPut("/{id:long}", async (long id, UpdateRentRequestCommand command, ISender sender) =>
        {
            if (id != command.RequestId) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateRentRequest")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPost("/{id:long}/start", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new StartRentalCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("StartRental")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPost("/{id:long}/complete", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new CompleteRentalCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CompleteRentalRequest")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}
