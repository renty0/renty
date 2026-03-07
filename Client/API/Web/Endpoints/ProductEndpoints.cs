using Application.Features.Products;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class ProductEndpoints
{
    public static void MapProductEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/products").WithTags("Products").RequireAuthorization();

        group.MapGet("/", async (int pageNumber, int pageSize, int? subcategoryId, int? categoryId,
            string? searchTerm, decimal? minPrice, decimal? maxPrice, string? color,
            string? sortBy, string? sortOrder, ISender sender) =>
            Api.Ok(await sender.Send(new GetProductsQuery(
                pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10,
                subcategoryId, categoryId, searchTerm, minPrice, maxPrice, color, sortBy, sortOrder))))
        .WithName("GetProducts")
        .Produces<ApiResponse<GetProductsResponse>>(StatusCodes.Status200OK);

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new GetProductByIdQuery(id));
            return r.Success ? Api.Ok(r) : Api.Fail("Not found", 404);
        })
        .WithName("GetProductById")
        .Produces<ApiResponse<GetProductByIdResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateProductCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            return r.Success ? Api.Created(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CreateProduct")
        .Produces<ApiResponse<CreateProductResponse>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPut("/{id:long}", async (long id, UpdateProductCommand command, ISender sender) =>
        {
            if (id != command.Id) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateProduct")
        .Produces<ApiResponse<UpdateProductResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteProductCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("DeleteProduct")
        .Produces<ApiResponse<DeleteProductResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}
