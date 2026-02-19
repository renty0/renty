using Application.Features.Products;
using MediatR;
using Microsoft.AspNetCore.Http.HttpResults;

namespace Web.Endpoints;

public static class ProductEndpoints
{
    public static void MapProductEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/products")
            .WithTags("Products")
            .RequireAuthorization();

        group.MapGet("/", async Task<Ok<GetProductsResponse>> (
            int pageNumber,
            int pageSize,
            int? subcategoryId,
            int? categoryId,
            string? searchTerm,
            decimal? minPrice,
            decimal? maxPrice,
            string? color,
            string? sortBy,
            string? sortOrder,
            ISender sender) =>
        {
            var result = await sender.Send(new GetProductsQuery(
                PageNumber: pageNumber > 0 ? pageNumber : 1,
                PageSize: pageSize > 0 ? pageSize : 10,
                SubcategoryId: subcategoryId,
                CategoryId: categoryId,
                SearchTerm: searchTerm,
                minPrice: minPrice,
                maxPrice: maxPrice,
                color: color,
                sortBy: sortBy,
                sortOrder: sortOrder
            ));
            return TypedResults.Ok(result);
        })
        .WithName("GetProducts")
        .WithOpenApi();

        group.MapGet("/{id:long}", async Task<Results<Ok<GetProductByIdResponse>, NotFound>> (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetProductByIdQuery(id));
            if (!result.Success)
            {
                return TypedResults.NotFound();
            }
            return TypedResults.Ok(result);
        })
        .WithName("GetProductById")
        .WithOpenApi();

        group.MapPost("/", async Task<Results<Created<CreateProductResponse>, BadRequest<CreateProductResponse>>> (CreateProductCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Created($"/api/products/{result.Product!.Id}", result);
        })
        .WithName("CreateProduct")
        .WithOpenApi();

        group.MapPut("/{id:long}", async Task<Results<Ok<UpdateProductResponse>, BadRequest<UpdateProductResponse>>> (long id, UpdateProductCommand command, ISender sender) =>
        {
            if (id != command.Id)
            {
                return TypedResults.BadRequest(new UpdateProductResponse(false, "ID mismatch", null));
            }
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("UpdateProduct")
        .WithOpenApi();

        group.MapDelete("/{id:long}", async Task<Results<Ok<DeleteProductResponse>, BadRequest<DeleteProductResponse>>> (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteProductCommand(id));
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("DeleteProduct")
        .WithOpenApi();
    }
}
