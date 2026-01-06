using Application.Common.Interfaces;
using Application.Features.RentableItems;
using Domain.Enums;
using MediatR;

namespace Web.Endpoints;

public static class RentableItemEndpoints
{
    public static void MapRentableItemEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/items")
            .WithTags("Rentable Items");

        // Public endpoint - browse available items
        group.MapGet("/", async (
            int pageNumber,
            int pageSize,
            string? searchTerm,
            int? categoryId,
            int? subcategoryId,
            string? city,
            string? country,
            decimal? minPrice,
            decimal? maxPrice,
            bool? isAvailableForDelivery,
            ISender sender) =>
        {
            var result = await sender.Send(new GetRentableItemsQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                searchTerm,
                categoryId,
                subcategoryId,
                city,
                country,
                minPrice,
                maxPrice,
                isAvailableForDelivery,
                null,
                ItemStatus.Available
            ));
            return Results.Ok(result);
        })
        .WithName("GetRentableItems")
        .WithOpenApi()
        .AllowAnonymous();

        // Get item details
        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetRentableItemByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetRentableItemById")
        .WithOpenApi()
        .AllowAnonymous();

        // Owner's items
        group.MapGet("/my-items", async (
            int pageNumber,
            int pageSize,
            ItemStatus? status,
            ISender sender,
            IUser currentUser) =>
        {
            if (currentUser.Id == null)
            {
                return Results.Unauthorized();
            }

            var result = await sender.Send(new GetRentableItemsQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                null, null, null, null, null, null, null, null,
                currentUser.Id.Value,
                status
            ));
            return Results.Ok(result);
        })
        .WithName("GetMyItems")
        .WithOpenApi()
        .RequireAuthorization();

        // Create item (Owner only)
        group.MapPost("/", async (CreateRentableItemCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/items/{result.ItemId}", result);
        })
        .WithName("CreateRentableItem")
        .WithOpenApi()
        .RequireAuthorization(policy => policy.RequireRole("Owner", "SuperAdmin", "Admin"));

        // Update item
        group.MapPut("/{id:long}", async (long id, UpdateRentableItemCommand command, ISender sender) =>
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
        .WithName("UpdateRentableItem")
        .WithOpenApi()
        .RequireAuthorization();

        // Update item status
        group.MapPatch("/{id:long}/status", async (long id, ItemStatus status, ISender sender) =>
        {
            var result = await sender.Send(new UpdateItemStatusCommand(id, status));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("UpdateItemStatus")
        .WithOpenApi()
        .RequireAuthorization();

        // Delete (archive) item
        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteRentableItemCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteRentableItem")
        .WithOpenApi()
        .RequireAuthorization();
    }
}
