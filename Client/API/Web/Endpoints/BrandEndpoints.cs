using Application.Features.Brands;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class BrandEndpoints
{
    public static void MapBrandEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/brands").WithTags("Brands");

        // GET /brands
        g.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? search,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortBy,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortOrder,
            ISender sender) =>
        {
            var r = await sender.Send(new GetBrandsQuery(search, page < 1 ? 1 : page, limit < 1 ? 50 : limit));
            var data = new PagedResult<BrandDto>(
                r.Brands ?? [], r.Total, r.Page, r.Pages,
                SortBy: sortBy, SortOrder: sortOrder);
            return Api.Ok(data);
        })
        .WithName("GetBrands")
        .Produces<ApiResponse<List<BrandDto>>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        // GET /brands/:id
        g.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new GetBrandByIdQuery(id));
            return r.Found ? Api.Ok(r.Brand) : Api.Fail(r.Error ?? "Not found", 404);
        })
        .WithName("GetBrandById")
        .Produces<ApiResponse<BrandDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .AllowAnonymous();

        // POST /brands
        g.MapPost("/", async (CreateBrandCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(r.Brand);
        })
        .WithName("CreateBrand")
        .Produces<ApiResponse<BrandDto>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // PUT /brands/:id
        g.MapPut("/{id:int}", async (int id, UpdateBrandCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { Id = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(r.Brand);
        })
        .WithName("UpdateBrand")
        .Produces<ApiResponse<BrandDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // DELETE /brands/:id
        g.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteBrandCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(new { message = "Brand deleted." });
        })
        .WithName("DeleteBrand")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
