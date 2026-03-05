using Application.Common.Models;
using Application.Features.Dashboard;
using Application.Features.Recommendations;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class DashboardEndpoints
{
    public static void MapDashboardEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/dashboard").WithTags("Dashboard").RequireAuthorization();

        group.MapGet("/admin", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetAdminDashboardQuery())))
        .WithName("GetAdminDashboard")
        .Produces<ApiResponse<AdminDashboardDto>>(StatusCodes.Status200OK)
        .RequireAuthorization(policy => policy.RequireRole("Admin"));

        group.MapGet("/owner", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetOwnerDashboardQuery())))
        .WithName("GetOwnerDashboard")
        .Produces<ApiResponse<OwnerDashboardDto>>(StatusCodes.Status200OK);

        group.MapGet("/renter", async (ISender sender) =>
            Api.Ok(await sender.Send(new GetRenterDashboardQuery())))
        .WithName("GetRenterDashboard")
        .Produces<ApiResponse<RenterDashboardDto>>(StatusCodes.Status200OK);
    }
}

public static class RecommendationEndpoints
{
    public static void MapRecommendationEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/recommendations").WithTags("Recommendations");

        group.MapGet("/personalized", async (int count, ISender sender) =>
            Api.Ok(await sender.Send(new GetPersonalizedRecommendationsQuery(count))))
        .WithName("GetPersonalizedRecommendations")
        .Produces<ApiResponse<List<RecommendationDto>>>(StatusCodes.Status200OK);

        group.MapGet("/trending", async (int count, ISender sender) =>
            Api.Ok(await sender.Send(new GetTrendingItemsQuery(count))))
        .WithName("GetTrendingItems")
        .Produces<ApiResponse<List<RecommendationDto>>>(StatusCodes.Status200OK);

        group.MapGet("/similar/{itemId}", async (long itemId, int count, ISender sender) =>
            Api.Ok(await sender.Send(new GetSimilarItemsQuery(itemId, count))))
        .WithName("GetSimilarItems")
        .Produces<ApiResponse<List<RecommendationDto>>>(StatusCodes.Status200OK);
    }
}
