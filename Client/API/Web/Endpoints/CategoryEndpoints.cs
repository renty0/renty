using Application.Features.Categories;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class CategoryEndpoints
{
    public static void MapCategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/categories").WithTags("Categories");

        // GET /categories
        g.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? search,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortBy,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? sortOrder,
            ISender sender) =>
        {
            var r = await sender.Send(new GetCategoriesQuery
            {
                SearchTerm = search,
                PageNumber = page < 1 ? 1 : page,
                PageSize   = limit < 1 ? 50 : limit
            });
            var data = new PagedResult<ProductCategoryDto>(
                r.Items ?? [], r.TotalCount, r.PageNumber, r.TotalPages,
                SortBy: sortBy, SortOrder: sortOrder);
            return Api.Ok(data);
        })
        .WithName("GetCategories")
        .Produces<ApiResponse<PagedResult<ProductCategoryDto>>>(StatusCodes.Status200OK)
        .AllowAnonymous();

        // GET /categories/:id
        g.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new GetCategoryByIdQuery(id));
            return r is null ? Api.Fail("Category not found", 404) : Api.Ok(r);
        })
        .WithName("GetCategoryById")
        .Produces<ApiResponse<ProductCategoryDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .AllowAnonymous();

        // POST /categories
        g.MapPost("/", async (CreateCategoryCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Created(r.Category);
        })
        .WithName("CreateCategory")
        .Produces<ApiResponse<ProductCategoryDto>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // PUT /categories/:id
        g.MapPut("/{id:int}", async (int id, UpdateCategoryCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { Id = id });
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Ok(r.Category);
        })
        .WithName("UpdateCategory")
        .Produces<ApiResponse<ProductCategoryDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // DELETE /categories/:id
        g.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteCategoryCommand(id));
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Ok(new { message = "Category deleted." });
        })
        .WithName("DeleteCategory")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
