using Application.Features.RentRequests;
using Domain.Enums;
using MediatR;

namespace Web.Endpoints;

public static class RentRequestEndpoints
{
    public static void MapRentRequestEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/rent-requests")
            .WithTags("Rent Requests")
            .RequireAuthorization();

        // Get my requests as a renter
        group.MapGet("/my-requests", async (
            int pageNumber,
            int pageSize,
            RentRequestStatus? status,
            ISender sender) =>
        {
            var result = await sender.Send(new GetRentRequestsQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                status,
                false // As renter
            ));
            return Results.Ok(result);
        })
        .WithName("GetMyRentRequests")
        .WithOpenApi();

        // Get requests for my items (as owner)
        group.MapGet("/received", async (
            int pageNumber,
            int pageSize,
            RentRequestStatus? status,
            ISender sender) =>
        {
            var result = await sender.Send(new GetRentRequestsQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                status,
                true // As owner
            ));
            return Results.Ok(result);
        })
        .WithName("GetReceivedRentRequests")
        .WithOpenApi();

        // Get request details
        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetRentRequestByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetRentRequestById")
        .WithOpenApi();

        // Create rent request (Renter)
        group.MapPost("/", async (CreateRentRequestCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/rent-requests/{result.RequestId}", result);
        })
        .WithName("CreateRentRequest")
        .WithOpenApi();

        // Respond to request (Owner) - Approve or Reject
        group.MapPost("/{id:long}/respond", async (long id, RespondToRentRequestCommand command, ISender sender) =>
        {
            if (id != command.RequestId)
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
        .WithName("RespondToRentRequest")
        .WithOpenApi();

        // Cancel request (Renter)
        group.MapPost("/{id:long}/cancel", async (long id, CancelRentRequestCommand command, ISender sender) =>
        {
            if (id != command.RequestId)
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
        .WithName("CancelRentRequest")
        .WithOpenApi();

        // Start rental (Owner)
        group.MapPost("/{id:long}/start", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new StartRentalCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("StartRental")
        .WithOpenApi();

        // Complete rental (Owner)
        group.MapPost("/{id:long}/complete", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new CompleteRentalCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("CompleteRental")
        .WithOpenApi();
    }
}
