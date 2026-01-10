using Application.Features.Categories;
using Application.Common.Models;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Web.Endpoints;

public static class CategoryEndpoints
{
    public static void MapCategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/categories")
            .WithTags("Categories")
            .RequireAuthorization();

        group.MapGet("/", async (int? pageNumber, int? pageSize, string? searchTerm, ISender sender) =>
        {
            var result = await sender.Send(new GetCategoriesQuery { 
                PageNumber = pageNumber ?? 1, 
                PageSize = pageSize ?? 10, 
                SearchTerm = searchTerm 
            });
            return Results.Ok(result);
        })
        .WithName("GetCategories")
        .Produces<PaginatedList<ProductCategoryDto>>(StatusCodes.Status200OK)
        .WithOpenApi();

        group.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new GetCategoryByIdQuery(id));
            return result is not null ? Results.Ok(result) : Results.NotFound();
        })
        .WithName("GetCategoryById")
        .Produces<ProductCategoryDto>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .WithOpenApi();

        group.MapPost("/", async (CreateCategoryCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/categories/{result.Category!.Id}", result);
        })
        .WithName("CreateCategory")
        .Produces<CreateCategoryResponse>(StatusCodes.Status201Created)
        .WithOpenApi();

        group.MapPut("/{id:int}", async (int id, UpdateCategoryCommand command, ISender sender) =>
        {
            if (id != command.Id)
            {
                return Results.BadRequest(new { Success = false, Message = "ID mismatch" });
            }
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("UpdateCategory")
        .Produces<UpdateCategoryResponse>(StatusCodes.Status200OK)
        .WithOpenApi();

        group.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteCategoryCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteCategory")
        .WithOpenApi();
    }
}
