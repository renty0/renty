using Application.Features.Favorites;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class FavoriteEndpoints
{
    public static void MapFavoriteEndpoints(this IEndpointRouteBuilder app)
    {
        // POST /items/:id/favorite
        app.MapPost("/api/v1/items/{id:guid}/favorite", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new AddFavoriteCommand(id));
            if (!r.Success)
                return r.Error!.Contains("already")
                    ? Api.Fail(r.Error, 409)
                    : Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new { message = "Added to favorites" });
        })
        .WithTags("Favorites").WithName("AddFavorite")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // DELETE /items/:id/favorite
        app.MapDelete("/api/v1/items/{id:guid}/favorite", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new RemoveFavoriteCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(new { message = "Removed from favorites" });
        })
        .WithTags("Favorites").WithName("RemoveFavorite")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.CanTransact);

        // GET /users/me/favorites
        app.MapGet("/api/v1/users/me/favorites", async (ISender sender) =>
        {
            var r = await sender.Send(new GetMyFavoritesQuery());
            return Api.Ok(r);
        })
        .WithTags("Favorites").WithName("GetMyFavorites")
        .Produces<ApiResponse<GetMyFavoritesResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.CanTransact);
    }
}
