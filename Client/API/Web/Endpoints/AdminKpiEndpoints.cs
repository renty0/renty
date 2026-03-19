using Application.Features.AdminKpis;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AdminKpiEndpoints
{
    public static void MapAdminKpiEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/admin").WithTags("Admin");

        g.MapGet("/kpis", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? period,
            [Microsoft.AspNetCore.Mvc.FromQuery] DateTime? from,
            [Microsoft.AspNetCore.Mvc.FromQuery] DateTime? to,
            ISender sender) =>
            Api.Ok(await sender.Send(new GetKpisQuery(period, from, to))))
        .WithName("GetAdminKpis")
        .Produces<ApiResponse<GetKpisResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);

        g.MapGet("/kpis/latest", async (ISender sender) =>
        {
            var r = await sender.Send(new GetLatestKpiQuery());
            return r.Found ? Api.Ok(r.Snapshot) : Api.Fail("No KPI data available.", 404);
        })
        .WithName("GetAdminLatestKpi")
        .Produces<ApiResponse<KpiSnapshotDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.AdminAccess);

        g.MapGet("/gap", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? period,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
            Api.Ok(await sender.Send(new GetGapAnalysisQuery(period, limit < 1 ? 20 : limit))))
        .WithName("GetAdminGapAnalysis")
        .Produces<ApiResponse<GetGapAnalysisResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
