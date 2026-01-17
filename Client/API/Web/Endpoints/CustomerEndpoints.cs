using Application.Features.Customers;
using MediatR;

namespace Web.Endpoints;

public static class CustomerEndpoints
{
    public static void MapCustomerEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/customers")
            .WithTags("Customers")
            .RequireAuthorization();

        group.MapGet("/", async (
            int pageNumber,
            int pageSize,
            string? searchTerm,
            string? gender,
            string? occupation,
            ISender sender) =>
        {
            var result = await sender.Send(new GetCustomersQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                searchTerm,
                gender,
                occupation
            ));
            return Results.Ok(result);
        })
        .WithName("GetCustomers")
        .WithOpenApi();

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetCustomerByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetCustomerById")
        .WithOpenApi();

        group.MapPost("/", async (CreateCustomerCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/customers/{result.Customer!.Id}", result);
        })
        .WithName("CreateCustomer")
        .WithOpenApi();

        group.MapPut("/{id:long}", async (long id, UpdateCustomerCommand command, ISender sender) =>
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
        .WithName("UpdateCustomer")
        .WithOpenApi();

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteCustomerCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteCustomer")
        .WithOpenApi();
    }
}
