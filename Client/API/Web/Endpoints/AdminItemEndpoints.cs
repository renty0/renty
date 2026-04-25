using Application.Features.AdminItems;
using Application.Features.Items;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AdminItemEndpoints
{
    public static void MapAdminItemEndpoints(this IEndpointRouteBuilder app)
    {
        // GET /admin/items/pending
        app.MapGet("/api/v1/admin/items/pending", async (ISender sender) =>
        {
            var result = await sender.Send(new GetPendingItemsQuery());
            return Api.Ok(result);
        })
        .WithTags("AdminItems").WithName("GetPendingItems")
        .Produces<ApiResponse<List<ItemListDto>>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);

        // POST /admin/items/{id}/review
        app.MapPost("/api/v1/admin/items/{id:guid}/review", async (Guid id, ReviewItemCommand baseCmd, ISender sender) =>
        {
            var cmd = baseCmd with { ItemId = id };
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { message = "Item review submitted." });
        })
        .WithTags("AdminItems").WithName("ReviewItem")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
