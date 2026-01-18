using Application.Features.GapAnalysis;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Web.Endpoints;

public static class GapAnalysisEndpoints
{
    public static void MapGapAnalysisEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("api/gap-analysis")
            .WithTags("Gap Analysis")
            .RequireAuthorization();

        group.MapGet("categories", async (ISender sender) => 
            await sender.Send(new GetCategoryGapAnalysisQuery()))
            .WithName("GetCategoryGapAnalysis")
            .Produces<List<Application.Common.Models.CategoryGapAnalysisDto>>(StatusCodes.Status200OK);

        group.MapGet("subcategories", async (ISender sender) => 
            await sender.Send(new GetSubcategoryGapAnalysisQuery()))
            .WithName("GetSubcategoryGapAnalysis")
            .Produces<List<Application.Common.Models.SubcategoryGapAnalysisDto>>(StatusCodes.Status200OK);

        group.MapGet("territories", async (ISender sender) => 
            await sender.Send(new GetTerritoryGapAnalysisQuery()))
            .WithName("GetTerritoryGapAnalysis")
            .Produces<List<Application.Common.Models.TerritoryGapAnalysisDto>>(StatusCodes.Status200OK);

        group.MapGet("summary", async (ISender sender) => 
            await sender.Send(new GetGapAnalysisSummaryQuery()))
            .WithName("GetGapAnalysisSummary")
            .Produces<Application.Common.Models.GapAnalysisSummaryDto>(StatusCodes.Status200OK);

        group.MapGet("actions", async (ISender sender) => 
            await sender.Send(new GetGapAnalysisActionPlanQuery()))
            .WithName("GetGapAnalysisActionPlan")
            .Produces<List<Application.Common.Models.GapActionPlanDto>>(StatusCodes.Status200OK);

        group.MapGet("trends", async (ISender sender) => 
            await sender.Send(new GetGapAnalysisTrendsQuery()))
            .WithName("GetGapAnalysisTrends")
            .Produces<List<Application.Common.Models.GapTrendDto>>(StatusCodes.Status200OK);

        group.MapGet("opportunity-loss", async (ISender sender) => 
            await sender.Send(new GetOpportunityLossQuery()))
            .WithName("GetOpportunityLoss")
            .Produces<List<Application.Common.Models.OpportunityLossDto>>(StatusCodes.Status200OK);

        group.MapGet("heatmap", async (ISender sender) => 
            await sender.Send(new GetGeographicGapHeatmapQuery()))
            .WithName("GetGeographicGapHeatmap")
            .Produces<List<Application.Common.Models.GeographicHeatmapDto>>(StatusCodes.Status200OK);

        group.MapGet("dead-stock", async (ISender sender) => 
            await sender.Send(new GetDeadStockAnalysisQuery()))
            .WithName("GetDeadStockAnalysis")
            .Produces<List<Application.Common.Models.DeadStockDto>>(StatusCodes.Status200OK);

        group.MapGet("smart-insights", async (ISender sender) => 
            await sender.Send(new GetSmartInsightsQuery()))
            .WithName("GetSmartInsights")
            .Produces<List<Application.Common.Models.SmartInsightDto>>(StatusCodes.Status200OK);
        group.MapPost("trigger", async (Application.Common.Interfaces.IGapAnalysisService service) =>
        {
            await service.RunAnalysisAsync();
            return Results.Ok(new { message = "Analysis triggered and results updated." });
        })
        .WithName("TriggerGapAnalysis")
        .Produces(StatusCodes.Status200OK);
    }
}
