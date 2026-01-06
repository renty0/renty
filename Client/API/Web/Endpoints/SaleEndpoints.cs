using Application.Features.Sales;
using MediatR;

namespace Web.Endpoints;

public static class SaleEndpoints
{
    public static void MapSaleEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/sales")
            .WithTags("Sales")
            .RequireAuthorization();

        group.MapGet("/", async (
            int pageNumber,
            int pageSize,
            DateOnly? startDate,
            DateOnly? endDate,
            long? customerId,
            long? productId,
            int? territoryId,
            string? orderNumber,
            ISender sender) =>
        {
            var result = await sender.Send(new GetSalesQuery(
                pageNumber > 0 ? pageNumber : 1,
                pageSize > 0 ? pageSize : 10,
                startDate,
                endDate,
                customerId,
                productId,
                territoryId,
                orderNumber
            ));
            return Results.Ok(result);
        })
        .WithName("GetSales")
        .WithOpenApi();

        group.MapGet("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new GetSaleByIdQuery(id));
            if (!result.Success)
            {
                return Results.NotFound(result);
            }
            return Results.Ok(result);
        })
        .WithName("GetSaleById")
        .WithOpenApi();

        group.MapPost("/", async (CreateSaleCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Created($"/api/sales/{result.Sale!.Id}", result);
        })
        .WithName("CreateSale")
        .WithOpenApi();

        group.MapPut("/{id:long}", async (long id, UpdateSaleCommand command, ISender sender) =>
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
        .WithName("UpdateSale")
        .WithOpenApi();

        group.MapDelete("/{id:long}", async (long id, ISender sender) =>
        {
            var result = await sender.Send(new DeleteSaleCommand(id));
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("DeleteSale")
        .WithOpenApi();

        // Analytics endpoints
        group.MapGet("/summary", async (
            DateOnly? startDate,
            DateOnly? endDate,
            int? territoryId,
            int? categoryId,
            ISender sender) =>
        {
            var result = await sender.Send(new GetSalesSummaryQuery(startDate, endDate, territoryId, categoryId));
            return Results.Ok(result);
        })
        .WithName("GetSalesSummary")
        .WithOpenApi();

        group.MapGet("/by-period", async (
            PeriodType period,
            DateOnly? startDate,
            DateOnly? endDate,
            int? territoryId,
            ISender sender) =>
        {
            var result = await sender.Send(new GetSalesByPeriodQuery(period, startDate, endDate, territoryId));
            return Results.Ok(result);
        })
        .WithName("GetSalesByPeriod")
        .WithOpenApi();

        group.MapGet("/top-products", async (
            int top,
            DateOnly? startDate,
            DateOnly? endDate,
            int? territoryId,
            ISender sender) =>
        {
            var result = await sender.Send(new GetTopProductsQuery(top > 0 ? top : 10, startDate, endDate, territoryId));
            return Results.Ok(result);
        })
        .WithName("GetTopProducts")
        .WithOpenApi();

        group.MapGet("/top-customers", async (
            int top,
            DateOnly? startDate,
            DateOnly? endDate,
            int? territoryId,
            ISender sender) =>
        {
            var result = await sender.Send(new GetTopCustomersQuery(top > 0 ? top : 10, startDate, endDate, territoryId));
            return Results.Ok(result);
        })
        .WithName("GetTopCustomers")
        .WithOpenApi();
    }
}
