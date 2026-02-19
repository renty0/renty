using Application.Features.Brands;
using MediatR;
using Microsoft.AspNetCore.Http.HttpResults;

namespace Web.Endpoints;

public static class BrandEndpoints
{
    public static void MapBrandEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/brands")
            .WithTags("Brands");

        group.MapGet("/", async Task<Ok<List<BrandDto>>> (string? searchTerm, ISender sender) =>
        {
            var result = await sender.Send(new GetBrandsQuery(searchTerm));
            return TypedResults.Ok(result);
        })
        .WithName("GetBrands")
        //.RequireAuthorization()
        .WithOpenApi();
    }
}
