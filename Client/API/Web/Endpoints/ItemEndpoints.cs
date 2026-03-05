using Application.Features.Items;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class ItemEndpoints
{
    public static void MapItemEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/items").WithTags("Items");

        // GET /items  — GetItemsQuery(CategoryId, SubcategoryId, City, MinPrice, MaxPrice, Type, Condition, Sort, Owner, Page, Limit)
        g.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            [Microsoft.AspNetCore.Mvc.FromQuery] int? categoryId,
            [Microsoft.AspNetCore.Mvc.FromQuery] int? subcategoryId,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? city,
            [Microsoft.AspNetCore.Mvc.FromQuery] decimal? minPrice,
            [Microsoft.AspNetCore.Mvc.FromQuery] decimal? maxPrice,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? type,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? condition,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sort,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortOrder,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? owner,
            ISender sender) =>
        {
            var r = await sender.Send(new GetItemsQuery(
                CategoryId:    categoryId,
                SubcategoryId: subcategoryId,
                City:          city,
                MinPrice:      minPrice,
                MaxPrice:      maxPrice,
                Type:          type,
                Condition:     condition,
                Sort:          sort,
                Owner:         owner,
                Page:          page < 1 ? 1 : page,
                Limit:         limit < 1 ? 20 : limit));

            var data = new PagedResult<ItemListDto>(
                r.Items, r.Total, r.Page, r.Pages,
                SortBy: sort, SortOrder: sortOrder);

            return Api.Ok(data);
        })
        .WithName("GetItems")
        .Produces<ApiResponse<PagedResult<ItemListDto>>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        // POST /items
        g.MapPost("/", async (CreateItemCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new ItemCreateData(r.ItemId));
        })
        .WithName("CreateItem")
        .Produces<ApiResponse<ItemCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /items/:id
        g.MapGet("/{id:guid}", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetItemByIdQuery(id));
            if (r is null) return Api.Fail("Item not found", 404);
            return Api.Ok(r);
        })
        .WithName("GetItemById")
        .Produces<ApiResponse<ItemDetailDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .AllowAnonymous();

        // PUT /items/:id
        g.MapPut("/{id:guid}", async (Guid id, UpdateItemCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(r.Item);
        })
        .WithName("UpdateItem")
        .Produces<ApiResponse<ItemDetailDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // DELETE /items/:id
        g.MapDelete("/{id:guid}", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteItemCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new { message = "Item deleted." });
        })
        .WithName("DeleteItem")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);
    }
}
