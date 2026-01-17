using Application.Features.Categories;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace Web.Endpoints;

public static class CategoryEndpoints
{
    public static void MapCategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/categories")
            .WithTags("Categories");
            //.RequireAuthorization();

        group.MapGet("/", async Task<Ok<PaginatedList<ProductCategoryDto>>> (
            int? pageNumber, 
            int? pageSize, 
            string? searchTerm, 
            string? sortBy,
            string? sortOrder,
            ISender sender) =>
        {
            var result = await sender.Send(new GetCategoriesQuery { 
                PageNumber = pageNumber ?? 1, 
                PageSize = pageSize ?? 10, 
                SearchTerm = searchTerm,
                SortBy = sortBy,
                SortOrder = sortOrder
            });
            return TypedResults.Ok(result);
        })
        .WithName("GetCategories")
        .WithOpenApi();

        group.MapGet("/{id:int}", async Task<Results<Ok<ProductCategoryDto>, NotFound>> (int id, ISender sender) =>
        {
            var result = await sender.Send(new GetCategoryByIdQuery(id));
            return result is not null ? TypedResults.Ok(result) : TypedResults.NotFound();
        })
        .WithName("GetCategoryById")
        .WithOpenApi();

        group.MapPost("/", async Task<Results<Ok<CreateCategoryResponse>, BadRequest<CreateCategoryResponse>>> (CreateCategoryCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("CreateCategory")
        .WithOpenApi();

        group.MapPut("/{id:int}", async Task<Results<Ok<UpdateCategoryResponse>, BadRequest<UpdateCategoryResponse>>> (int id, UpdateCategoryCommand command, ISender sender) =>
        {
            if (id != command.Id)
            {
                return TypedResults.BadRequest(new UpdateCategoryResponse(false, "ID mismatch", null));
            }
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("UpdateCategory")
        .WithOpenApi();

        group.MapDelete("/{id:int}", async Task<Results<Ok<DeleteCategoryResponse>, BadRequest<DeleteCategoryResponse>>> (int id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteCategoryCommand(id));
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("DeleteCategory")
        .WithOpenApi();
    }
}
