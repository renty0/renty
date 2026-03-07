using Application.Common.Interfaces;
using Application.Features.RentableItems;
using Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class RentableItemEndpoints
{
    public static void MapRentableItemEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/items").WithTags("Rentable Items");

        group.MapGet("/", async (int pageNumber, int pageSize, string? searchTerm,
            int? categoryId, int? subcategoryId, string? city, string? country,
            decimal? minPrice, decimal? maxPrice, bool? isAvailableForDelivery, ISender sender) =>
            Api.Ok(await sender.Send(new GetRentableItemsQuery(
                pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10,
                searchTerm, categoryId, subcategoryId, city, country,
                minPrice, maxPrice, isAvailableForDelivery, null, ItemStatus.Available))))
        .WithName("GetRentableItems")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new GetRentableItemByIdQuery(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Not found", 404);
        })
        .WithName("GetRentableItemById")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .AllowAnonymous();

        group.MapGet("/my-items", async (int pageNumber, int pageSize, ItemStatus? status,
            ISender sender, IUser currentUser) =>
        {
            if (currentUser.Id == null) return Api.Fail("Unauthorized", 401);
            var r = await sender.Send(new GetRentableItemsQuery(
                pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10,
                null, null, null, null, null, null, null, null, currentUser.Id.Value, status));
            return Api.Ok(r);
        })
        .WithName("GetMyItems")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        group.MapPost("/", async (CreateRentableItemCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            return r.Success ? Api.Created(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CreateRentableItem")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(policy => policy.RequireRole("Owner", "SuperAdmin", "Admin"));

        group.MapPut("/{id:long}", async (long id, UpdateRentableItemCommand command, ISender sender) =>
        {
            if (id != command.Id) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateRentableItem")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization();

        group.MapPatch("/{id:long}/status", async (long id, ItemStatus status, ISender sender) =>
        {
            var r = await sender.Send(new UpdateItemStatusCommand(id, status));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateItemStatus")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization();

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteRentableItemCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("DeleteRentableItem")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization();
    }
}
