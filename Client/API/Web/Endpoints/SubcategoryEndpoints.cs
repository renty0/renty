using Application.Features.Subcategories;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class SubcategoryEndpoints
{
    public static void MapSubcategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/subcategories").WithTags("Subcategories");

        // GET /subcategories
        g.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] int? categoryId,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? search,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortBy,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortOrder,
            ISender sender) =>
        {
            var r = await sender.Send(new GetSubcategoriesQuery(
                CategoryId:   categoryId,
                PageNumber:   page < 1 ? 1 : page,
                PageSize:     limit < 1 ? 50 : limit,
                SearchString: search));

            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");

            var paged = r.Subcategories!;
            var data = new PagedResult<ProductSubcategoryDto>(
                paged.Items ?? [], paged.TotalCount, paged.PageNumber, paged.TotalPages,
                SortBy: sortBy, SortOrder: sortOrder);
            return Api.Ok(data);
        })
        .WithName("GetSubcategories")
        .Produces<ApiResponse<PagedResult<ProductSubcategoryDto>>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        // GET /subcategories/:id
        g.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new GetSubcategoryByIdQuery(id));
            return r.Success ? Api.Ok(r.Subcategory) : Api.Fail(r.Message ?? "Not found", 404);
        })
        .WithName("GetSubcategoryById")
        .Produces<ApiResponse<ProductSubcategoryDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .AllowAnonymous();

        // GET /categories/:categoryId/subcategories
        app.MapGet("/api/v1/categories/{categoryId:int}/subcategories", async (
            int categoryId,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortBy,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortOrder,
            ISender sender) =>
        {
            var r = await sender.Send(new GetSubcategoriesQuery(
                CategoryId: categoryId,
                PageNumber:  page < 1 ? 1 : page,
                PageSize:    limit < 1 ? 50 : limit));

            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");

            var paged = r.Subcategories!;
            var data = new PagedResult<ProductSubcategoryDto>(
                paged.Items ?? [], paged.TotalCount, paged.PageNumber, paged.TotalPages,
                SortBy: sortBy, SortOrder: sortOrder);
            return Api.Ok(data);
        })
        .WithTags("Subcategories")
        .WithName("GetSubcategoriesByCategory")
        .Produces<ApiResponse<PagedResult<ProductSubcategoryDto>>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        // POST /subcategories
        g.MapPost("/", async (CreateSubcategoryCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Created(r.Subcategory);
        })
        .WithName("CreateSubcategory")
        .Produces<ApiResponse<ProductSubcategoryDto>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // PUT /subcategories/:id
        g.MapPut("/{id:int}", async (int id, UpdateSubcategoryCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { Id = id });
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Ok(r.Subcategory);
        })
        .WithName("UpdateSubcategory")
        .Produces<ApiResponse<ProductSubcategoryDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // DELETE /subcategories/:id
        g.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteSubcategoryCommand(id));
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Ok(new { message = "Subcategory deleted." });
        })
        .WithName("DeleteSubcategory")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
