using Application.Features.Subcategories;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;

namespace Web.Endpoints;

public static class SubcategoryEndpoints
{
    public static void MapSubcategoryEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/subcategories")
            .WithTags("Subcategories");
            //.RequireAuthorization();

        group.MapGet("/", async Task<Ok<GetSubcategoriesResponse>> (
            ISender sender, 
            int? categoryId = null, 
            int pageNumber = 1, 
            int pageSize = 10, 
            string? searchString = null,
            string? sortBy = null,
            string? sortOrder = null) =>
        {
            var query = new GetSubcategoriesQuery(categoryId, pageNumber, pageSize, searchString, sortBy, sortOrder);
            var result = await sender.Send(query);
            return TypedResults.Ok(result);
        })
        .WithName("GetSubcategories")
        .WithOpenApi();

        group.MapGet("/{id:int}", async Task<Results<Ok<GetSubcategoryByIdResponse>, NotFound>> (int id, ISender sender) =>
        {
            var result = await sender.Send(new GetSubcategoryByIdQuery(id));
            if (!result.Success || result.Subcategory is null)
            {
                return TypedResults.NotFound();
            }
            return TypedResults.Ok(result);
        })
        .WithName("GetSubcategoryById")
        .WithOpenApi();

        group.MapPost("/", async Task<Results<Ok<CreateSubcategoryResponse>, BadRequest<CreateSubcategoryResponse>>> (CreateSubcategoryCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("CreateSubcategory")
        .WithOpenApi();

        group.MapPut("/{id:int}", async Task<Results<Ok<UpdateSubcategoryResponse>, BadRequest<UpdateSubcategoryResponse>>> (int id, UpdateSubcategoryCommand command, ISender sender) =>
        {
            if (id != command.Id)
            {
                return TypedResults.BadRequest(new UpdateSubcategoryResponse(false, "ID mismatch", null));
            }
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("UpdateSubcategory")
        .WithOpenApi();

        group.MapDelete("/{id:int}", async Task<Results<Ok<DeleteSubcategoryResponse>, BadRequest<DeleteSubcategoryResponse>>> (int id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteSubcategoryCommand(id));
            if (!result.Success)
            {
                return TypedResults.BadRequest(result);
            }
            return TypedResults.Ok(result);
        })
        .WithName("DeleteSubcategory")
        .WithOpenApi();
    }
}
