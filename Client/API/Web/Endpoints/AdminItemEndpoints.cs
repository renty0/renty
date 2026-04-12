using Application.Features.AdminItems;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AdminItemEndpoints
{
    public static void MapAdminItemEndpoints(this IEndpointRouteBuilder app)
    {
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
