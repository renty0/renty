using Application.Features.GapAnalysis;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Web.Endpoints;

public static class KpiEndpoints
{
    public static void MapKpiEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/kpis")
            .WithTags("KPIs")
            .RequireAuthorization();

        group.MapGet("/", async (ISender sender) => 
            await sender.Send(new GetGlobalKPIsQuery()))
            .WithName("GetGlobalKPIs")
            .Produces<Application.Common.Models.GlobalKPIsDto>(StatusCodes.Status200OK);
    }
}
