using Application.Features.Orders;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class OrderEndpoints
{
    public static void MapOrderEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/orders").WithTags("Orders");

        // POST /orders
        g.MapPost("/", async (CreateOrderCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new OrderCreateData(r.OrderId, r.TotalAmount, r.Status));
        })
        .WithName("CreateOrder")
        .Produces<ApiResponse<OrderCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /orders
        g.MapGet("/", async (ISender sender) =>
        {
            var r = await sender.Send(new GetOrdersQuery());
            return Api.Ok(r);
        })
        .WithName("GetOrders")
        .Produces<ApiResponse<Application.Features.Orders.GetOrdersResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.CanTransact);

        // GET /orders/:id
        g.MapGet("/{id:guid}", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetOrderByIdQuery(id));
            if (!r.Found) return r.Error == "Forbidden." ? Api.Fail("Forbidden", 403) : Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r.Order);
        })
        .WithName("GetOrderById")
        .Produces<ApiResponse<OrderDetailDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.CanTransact);
    }
}
