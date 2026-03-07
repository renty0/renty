using Application.Features.Analytics;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AnalyticsEndpoints
{
    public static void MapAnalyticsEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("api/analytics").WithTags("Analytics").RequireAuthorization();

        group.MapGet("sales-trend", async (ISender sender, string interval = "monthly") =>
            Api.Ok(await sender.Send(new GetSalesTrendQuery(interval))))
            .WithName("GetSalesTrend")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("customer-demographics", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetCustomerDemographicsQuery())))
            .WithName("GetCustomerDemographics")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("product-performance", async (ISender sender, int top = 10) =>
            Api.Ok(await sender.Send(new GetProductPerformanceQuery(top))))
            .WithName("GetProductPerformance")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("inventory-stats", async (ISender sender, int top = 5) =>
            Api.Ok(await sender.Send(new GetInventoryStatsQuery(top))))
            .WithName("GetInventoryStats")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("return-analytics", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetReturnAnalyticsQuery())))
            .WithName("GetReturnAnalytics")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);
    }
}
