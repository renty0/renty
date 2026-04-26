using Application.Features.Rentals;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class RentalEndpoints
{
    public static void MapRentalEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/rentals").WithTags("Rentals");

        // POST /rentals
        g.MapPost("/", async (CreateRentalCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new RentalCreateData(r.RentalId, r.OrderId, r.RentalPrice, r.DepositAmount, r.Status));
        })
        .WithName("CreateRental")
        .Produces<ApiResponse<RentalCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /rentals
        g.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? status,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            var r = await sender.Send(new GetRentalsQuery(status, page < 1 ? 1 : page, limit < 1 ? 20 : limit));
            return Api.Ok(r);
        })
        .WithName("GetRentals")
        .Produces<ApiResponse<Application.Features.Rentals.GetRentalsResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.NonExpert);

        // GET /rentals/:id
        g.MapGet("/{id:guid}", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetRentalByIdQuery(id));
            if (!r.Found) return r.Error == "Forbidden." ? Api.Fail("Forbidden", 403) : Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r.Rental);
        })
        .WithName("GetRentalById")
        .Produces<ApiResponse<RentalDetailDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.NonExpert);

        // PUT /rentals/:id/confirm
        g.MapPut("/{id:guid}/confirm", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new ConfirmRentalCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new RentalStatusData(r.Status));
        })
        .WithName("ConfirmRental")
        .Produces<ApiResponse<RentalStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/verify-handoff
        g.MapPut("/{id:guid}/verify-handoff", async (Guid id, [Microsoft.AspNetCore.Mvc.FromBody] string code, ISender sender) =>
        {
            var r = await sender.Send(new VerifyHandoffCommand(id, code));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new RentalStatusData(r.Status));
        })
        .WithName("VerifyHandoff")
        .Produces<ApiResponse<RentalStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // POST /rentals/:id/photos
        g.MapPost("/{id:guid}/photos", async (Guid id, UploadRentalPhotosBody body, ISender sender) =>
        {
            var cmd = new UploadRentalPhotosCommand(id, body.ImageIds, body.Type);
            var success = await sender.Send(cmd);
            return success ? Api.Ok(new { }) : Api.Fail("Failed to upload photos", 400);
        })
        .WithName("UploadRentalPhotos")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/complete
        g.MapPut("/{id:guid}/complete", async (Guid id,
            [Microsoft.AspNetCore.Mvc.FromQuery] bool damaged,
            ISender sender) =>
        {
            var r = await sender.Send(new CompleteRentalCommand(id, damaged));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new RentalCompleteData(r.RentalId, r.Status, r.LateFee, r.DepositStatus));
        })
        .WithName("CompleteRental")
        .Produces<ApiResponse<RentalCompleteData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/cancel
        g.MapPut("/{id:guid}/cancel", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new CancelRentalCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new RentalStatusData(r.Status));
        })
        .WithName("CancelRental")
        .Produces<ApiResponse<RentalStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);
    }
}
