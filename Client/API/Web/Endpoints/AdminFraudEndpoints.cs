using Application.Features.AdminFraud;
using Application.Features.AdminUsers;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AdminFraudEndpoints
{
    public static void MapAdminFraudEndpoints(this IEndpointRouteBuilder app)
    {
        // GET /admin/fraud
        app.MapGet("/api/v1/admin/fraud", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? decision,
            [Microsoft.AspNetCore.Mvc.FromQuery] double? minRisk,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            var r = await sender.Send(new GetFraudLogsQuery(decision, minRisk, page < 1 ? 1 : page, limit < 1 ? 20 : limit));
            return Api.Ok(r);
        })
        .WithTags("Admin").WithName("GetFraudLogs")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);

        // GET /admin/users
        app.MapGet("/api/v1/admin/users", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            var r = await sender.Send(new GetAdminUsersQuery(page < 1 ? 1 : page, limit < 1 ? 20 : limit));
            return Api.Ok(r);
        })
        .WithTags("Admin").WithName("GetAdminUsers")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);

        // PUT /admin/users/:id/status
        app.MapPut("/api/v1/admin/users/{id:long}/status", async (long id, UpdateUserStatusCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { UserId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(new { userId = r.UserId, isActive = r.IsActive });
        })
        .WithTags("Admin").WithName("UpdateUserStatus")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.SuperAdminOnly);
    }
}
