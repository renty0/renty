using Application.Features.Products;
using MediatR;

namespace Web.Endpoints;

public static class ProductEndpoints
{
    public static void MapProductEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/products")
            .WithTags("Products")
            .RequireAuthorization();

        group.MapGet("/", async (
            int pageNumber,
            int pageSize,
            int? subcategoryId,
            int? categoryId,
            string? searchTerm,
            decimal? minPrice,
            decimal? maxPrice,
            string? color,
            ISender sender) =>
        {
            var result = await sender.Send(new GetProductsQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                subcategoryId,
                categoryId,
                searchTerm,
                minPrice,
                maxPrice,
                color
            ));
            return Results.Ok(result);
        })
        .WithName("GetProducts")
        .WithOpenApi();

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetProductByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetProductById")
        .WithOpenApi();

        group.MapPost("/", async (CreateProductCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/products/{result.Product!.Id}", result);
        })
        .WithName("CreateProduct")
        .WithOpenApi();

        group.MapPut("/{id:long}", async (long id, UpdateProductCommand command, ISender sender) =>
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
        .WithName("UpdateProduct")
        .WithOpenApi();

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteProductCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteProduct")
        .WithOpenApi();
    }
}
