using Application.Features.GapAnalysis;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class KpiEndpoints
{
    public static void MapKpiEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/kpis").WithTags("KPIs").RequireAuthorization();

        group.MapGet("/", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetGlobalKPIsQuery())))
            .WithName("GetGlobalKPIs")
            .Produces<ApiResponse<object>>(StatusCodes.Status200OK);
    }
}
