using Application.Features.Sales;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class SaleEndpoints
{
    public static void MapSaleEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/sales").WithTags("Sales").RequireAuthorization();

        group.MapGet("/", async (int pageNumber, int pageSize, DateOnly? startDate, DateOnly? endDate,
            long? customerId, long? productId, int? territoryId, string? orderNumber, ISender sender) =>
            Api.Ok(await sender.Send(new GetSalesQuery(
                pageNumber > 0 ? pageNumber : 1, pageSize > 0 ? pageSize : 10,
                startDate, endDate, customerId, productId, territoryId, orderNumber))))
        .WithName("GetSales")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new GetSaleByIdQuery(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Not found", 404);
        })
        .WithName("GetSaleById")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateSaleCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            return r.Success ? Api.Created(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("CreateSale")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapPut("/{id:long}", async (long id, UpdateSaleCommand command, ISender sender) =>
        {
            if (id != command.Id) return Api.Fail("ID mismatch");
            var r = await sender.Send(command);
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("UpdateSale")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteSaleCommand(id));
            return r.Success ? Api.Ok(r) : Api.Fail(r.Message ?? "Bad request");
        })
        .WithName("DeleteSale")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest);

        group.MapGet("/summary", async (DateOnly? startDate, DateOnly? endDate, int? territoryId, int? categoryId, ISender sender) =>
            Api.Ok(await sender.Send(new GetSalesSummaryQuery(startDate, endDate, territoryId, categoryId))))
        .WithName("GetSalesSummary")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/by-period", async (PeriodType period, DateOnly? startDate, DateOnly? endDate, int? territoryId, ISender sender) =>
            Api.Ok(await sender.Send(new GetSalesByPeriodQuery(period, startDate, endDate, territoryId))))
        .WithName("GetSalesByPeriod")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/top-products", async (int top, DateOnly? startDate, DateOnly? endDate, int? territoryId, ISender sender) =>
            Api.Ok(await sender.Send(new GetTopProductsQuery(top > 0 ? top : 10, startDate, endDate, territoryId))))
        .WithName("GetTopProducts")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("/top-customers", async (int top, DateOnly? startDate, DateOnly? endDate, int? territoryId, ISender sender) =>
            Api.Ok(await sender.Send(new GetTopCustomersQuery(top > 0 ? top : 10, startDate, endDate, territoryId))))
        .WithName("GetTopCustomers")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);
    }
}
