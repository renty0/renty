using Application.Features.Analytics;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Web.Endpoints;

public static class AnalyticsEndpoints
{
    public static void MapAnalyticsEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("api/analytics")
            .WithTags("Analytics")
            .RequireAuthorization();

        group.MapGet("sales-trend", async (ISender sender, string interval = "monthly") => 
            await sender.Send(new GetSalesTrendQuery(interval)))
            .WithName("GetSalesTrend")
            .Produces<List<Application.Common.Models.SalesTrendDto>>(StatusCodes.Status200OK);

        group.MapGet("customer-demographics", async (ISender sender) => 
            await sender.Send(new GetCustomerDemographicsQuery()))
            .WithName("GetCustomerDemographics")
            .Produces<Application.Common.Models.CustomerDemographicsDto>(StatusCodes.Status200OK);

        group.MapGet("product-performance", async (ISender sender, int top = 10) => 
            await sender.Send(new GetProductPerformanceQuery(top)))
            .WithName("GetProductPerformance")
            .Produces<Application.Common.Models.ProductPerformanceDto>(StatusCodes.Status200OK);

        group.MapGet("inventory-stats", async (ISender sender, int top = 5) => 
            await sender.Send(new GetInventoryStatsQuery(top)))
            .WithName("GetInventoryStats")
            .Produces<Application.Common.Models.InventoryStatsDto>(StatusCodes.Status200OK);

        group.MapGet("return-analytics", async (ISender sender) => 
            await sender.Send(new GetReturnAnalyticsQuery()))
            .WithName("GetReturnAnalytics")
            .Produces<Application.Common.Models.ReturnAnalyticsDto>(StatusCodes.Status200OK);
    }
}
