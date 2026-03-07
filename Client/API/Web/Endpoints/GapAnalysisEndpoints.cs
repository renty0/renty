using Application.Features.GapAnalysis;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class GapAnalysisEndpoints
{
    public static void MapGapAnalysisEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("api/gap-analysis").WithTags("Gap Analysis").RequireAuthorization();

        group.MapGet("categories", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetCategoryGapAnalysisQuery())))
            .WithName("GetCategoryGapAnalysis")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("subcategories", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetSubcategoryGapAnalysisQuery())))
            .WithName("GetSubcategoryGapAnalysis")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("territories", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetTerritoryGapAnalysisQuery())))
            .WithName("GetTerritoryGapAnalysis")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("summary", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetGapAnalysisSummaryQuery())))
            .WithName("GetGapAnalysisSummary")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("actions", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetGapAnalysisActionPlanQuery())))
            .WithName("GetGapAnalysisActionPlan")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("trends", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetGapAnalysisTrendsQuery())))
            .WithName("GetGapAnalysisTrends")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("opportunity-loss", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetOpportunityLossQuery())))
            .WithName("GetOpportunityLoss")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("heatmap", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetGeographicGapHeatmapQuery())))
            .WithName("GetGeographicGapHeatmap")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("dead-stock", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetDeadStockAnalysisQuery())))
            .WithName("GetDeadStockAnalysis")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapGet("smart-insights", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetSmartInsightsQuery())))
            .WithName("GetSmartInsights")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);

        group.MapPost("trigger", async (Application.Common.Interfaces.IGapAnalysisService service) =>
        {
            await service.RunAnalysisAsync();
            return Api.Ok(new { message = "Analysis triggered." });
        })
        .WithName("TriggerGapAnalysis")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK);
    }
}
