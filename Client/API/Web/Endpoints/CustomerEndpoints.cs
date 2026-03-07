using Application.Features.Customers;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class CustomerEndpoints
{
    public static void MapCustomerEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/customers").WithTags("Customers").RequireAuthorization();

        group.MapGet("/", async (int pageNumber, int pageSize, string? searchTerm, string? gender, string? occupation, ISender sender) =>
        {
            var result = await sender.Send(new GetCustomersQuery(pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10, searchTerm, gender, occupation));
            return Api.Ok(result);
        })
        .WithName("GetCustomers")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetCustomerByIdQuery(id));
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Not found", 404);
        })
        .WithName("GetCustomerById")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateCustomerCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Success ? Api.Created(result) : Api.Fail(result.Message ?? "Bad request");
        })
        .WithName("CreateCustomer")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPut("/{id:long}", async (long id, UpdateCustomerCommand command, ISender sender) =>
        {
            if (id != command.Id) return Api.Fail("ID mismatch");
            var result = await sender.Send(command);
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Bad request");
        })
        .WithName("UpdateCustomer")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteCustomerCommand(id));
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Bad request");
        })
        .WithName("DeleteCustomer")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);
    }
}
