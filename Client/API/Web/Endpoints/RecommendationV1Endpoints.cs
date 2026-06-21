using Application.Features.ItemRecommendations;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class RecommendationV1Endpoints
{
    public static void MapRecommendationV1Endpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/recommendations").WithTags("Recommendations");

        // GET /recommendations – public endpoint; returns trending items for guests
        g.MapGet("/", async (ISender sender) =>
        {
            var r = await sender.Send(new GetRecommendationsQuery());
            return Api.Ok(r);
        })
        .WithName("GetRecommendationsV1")
        .Produces<ApiResponse<GetRecommendationsResponse>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        // PUT /recommendations/:id/click
        g.MapPut("/{id:guid}/click", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new RecordRecommendationClickCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(new { message = "Click recorded" });
        })
        .WithName("RecordRecommendationClick")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.CanTransact);
    }
}
