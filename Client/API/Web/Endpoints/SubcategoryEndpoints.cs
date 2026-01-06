using Application.Features.Subcategories;
using MediatR;

namespace Web.Endpoints;

public static class SubcategoryEndpoints
{
    public static void MapSubcategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/subcategories")
            .WithTags("Subcategories")
            .RequireAuthorization();

        group.MapGet("/", async (int? categoryId, ISender sender) =>
        {
            var result = await sender.Send(new GetSubcategoriesQuery(categoryId));
            return Results.Ok(result);
        })
        .WithName("GetSubcategories")
        .WithOpenApi();

        group.MapGet("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new GetSubcategoryByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetSubcategoryById")
        .WithOpenApi();

        group.MapPost("/", async (CreateSubcategoryCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/subcategories/{result.Subcategory!.Id}", result);
        })
        .WithName("CreateSubcategory")
        .WithOpenApi();

        group.MapPut("/{id:int}", async (int id, UpdateSubcategoryCommand command, ISender sender) =>
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
        .WithName("UpdateSubcategory")
        .WithOpenApi();

        group.MapDelete("/{id:int}", async (int id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteSubcategoryCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteSubcategory")
        .WithOpenApi();
    }
}
