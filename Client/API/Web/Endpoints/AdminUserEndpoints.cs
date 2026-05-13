using Application.Features.AdminFraud;
using Application.Features.AdminUsers;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;

namespace Web.Endpoints;

public static class AdminUserEndpoints
{
    public static void MapAdminUserEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/admin")
            .WithTags("Admin")
            .RequireAuthorization(Policies.AdminAccess);

        // GET /admin/fraud
        group.MapGet("/fraud", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? decision,
            [Microsoft.AspNetCore.Mvc.FromQuery] double? minRisk,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            var r = await sender.Send(new GetFraudLogsQuery(decision, minRisk, page < 1 ? 1 : page, limit < 1 ? 20 : limit));
            return Api.Ok(r);
        })
        .WithName("GetFraudLogs")
        .Produces<ApiResponse<GetFraudLogsResponse>>(StatusCodes.Status200OK);

        // GET /admin/users
        group.MapGet("/users", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? searchTerm,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            var r = await sender.Send(new GetAdminUsersQuery(page < 1 ? 1 : page, limit < 1 ? 20 : limit, searchTerm));
            return Api.Ok(r);
        })
        .WithName("GetAdminUsers")
        .Produces<ApiResponse<GetAdminUsersResponse>>(StatusCodes.Status200OK);

        // POST /admin/users
        group.MapPost("/users", async (CreateAdminUserCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Failed to create user", 400);
            return Api.Ok(r);
        })
        .WithName("CreateAdminUser")
        .Produces<ApiResponse<CreateAdminUserResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);

        // PUT /admin/users/:id/status
        group.MapPut("/users/{id:long}/status", async (long id, UpdateUserStatusCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { UserId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(new { userId = r.UserId, isActive = r.IsActive });
        })
        .WithName("UpdateUserStatus")
        .Produces<ApiResponse<UpdateUserStatusResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.AdminAccess);

        // PUT /admin/users/:id/roles
        group.MapPut("/users/{id:long}/roles", async (long id, AssignUserRolesCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { UserId = id });
            if (!r.Succeeded) return Api.Fail(r.Errors.FirstOrDefault() ?? "Not found", 404);
            return Api.Ok(r);
        })
        .WithName("AssignUserRoles")
        .Produces<ApiResponse<Application.Common.Models.Result>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
