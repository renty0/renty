using Application.Features.Reviews;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class ReviewEndpoints
{
    public static void MapReviewEndpoints(this IEndpointRouteBuilder app)
    {
        // POST /rentals/:id/review
        app.MapPost("/api/v1/rentals/{id:guid}/review", async (Guid id, CreateReviewCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { RentalId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new ReviewCreateData(r.ReviewId, r.Rating, r.Comment));
        })
        .WithTags("Reviews").WithName("CreateReview")
        .Produces<ApiResponse<ReviewCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /items/:id/reviews
        app.MapGet("/api/v1/items/{id:guid}/reviews", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetItemReviewsQuery(id));
            return Api.Ok(r);
        })
        .WithTags("Reviews").WithName("GetItemReviews")
        .Produces<ApiResponse<GetItemReviewsResponse>>(StatusCodes.Status200OK)
        .AllowAnonymous();
    }
}
