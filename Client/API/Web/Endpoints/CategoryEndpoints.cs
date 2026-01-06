using Application.Features.Categories;
using MediatR;

namespace Web.Endpoints;

public static class CategoryEndpoints
{
    public static void MapCategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/categories")
            .WithTags("Categories")
            .RequireAuthorization();

        group.MapGet("/", async (ISender sender) =>
        {
            var result = await sender.Send(new GetCategoriesQuery());
            return Results.Ok(result);
        })
        .WithName("GetCategories")
        .WithOpenApi();

        group.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new GetCategoryByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetCategoryById")
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
