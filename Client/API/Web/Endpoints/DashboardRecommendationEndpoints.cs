using Application.Common.Models;
using Application.Features.Dashboard;
using Application.Features.Recommendations;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Web.Endpoints;

public static class DashboardEndpoints
{
    public static void MapDashboardEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/dashboard")
            .WithTags("Dashboard")
            .RequireAuthorization();

        group.MapGet("/admin", async (ISender sender) =>
        {
            return Results.Ok(await sender.Send(new GetAdminDashboardQuery()));
        })
        .WithName("GetAdminDashboard")
        .Produces<AdminDashboardDto>(StatusCodes.Status200OK)
        .RequireAuthorization(policy => policy.RequireRole("Admin"));

        group.MapGet("/owner", async (ISender sender) =>
        {
            return Results.Ok(await sender.Send(new GetOwnerDashboardQuery()));
        })
        .WithName("GetOwnerDashboard")
        .Produces<OwnerDashboardDto>(StatusCodes.Status200OK);

        group.MapGet("/renter", async (ISender sender) =>
        {
            return Results.Ok(await sender.Send(new GetRenterDashboardQuery()));
        })
        .WithName("GetRenterDashboard")
        .Produces<RenterDashboardDto>(StatusCodes.Status200OK);
    }
}

public static class RecommendationEndpoints
{
    public static void MapRecommendationEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/recommendations")
            .WithTags("Recommendations");

        group.MapGet("/personalized", async (int count, ISender sender) =>
        {
            return Results.Ok(await sender.Send(new GetPersonalizedRecommendationsQuery(count)));
        })
        .WithName("GetPersonalizedRecommendations")
        .Produces<List<RecommendationDto>>(StatusCodes.Status200OK);

        group.MapGet("/trending", async (int count, ISender sender) =>
        {
            return Results.Ok(await sender.Send(new GetTrendingItemsQuery(count)));
        })
        .WithName("GetTrendingItems")
        .Produces<List<RecommendationDto>>(StatusCodes.Status200OK);

        group.MapGet("/similar/{itemId}", async (long itemId, int count, ISender sender) =>
        {
            return Results.Ok(await sender.Send(new GetSimilarItemsQuery(itemId, count)));
        })
        .WithName("GetSimilarItems")
        .Produces<List<RecommendationDto>>(StatusCodes.Status200OK);
    }
}
