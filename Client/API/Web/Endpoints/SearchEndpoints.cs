using Application.Features.Search;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class SearchEndpoints
{
    public static void MapSearchEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/search").WithTags("Search");

        group.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string q,
            [Microsoft.AspNetCore.Mvc.FromQuery] int? categoryId,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? city,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            if (string.IsNullOrWhiteSpace(q))
                return Api.Fail("Query parameter 'q' is required.");

            var r = await sender.Send(new SearchItemsQuery(
                q, categoryId, city,
                page < 1 ? 1 : page,
                limit < 1 ? 20 : limit));

            return Api.Ok(r);
        })
        .WithName("SearchItems")
        .Produces<ApiResponse<SearchItemsResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();
    }
}
