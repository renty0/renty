using Application.Features.AdminRoles;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Web.Responses;
using Application.Common.Interfaces;
using Application.Common.Models;

namespace Web.Endpoints;

public static class AdminRoleEndpoints
{
    public static void MapAdminRoleEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/admin")
            .WithTags("Admin")
            .RequireAuthorization(Policies.AdminAccess);

        // GET /admin/roles
        group.MapGet("/roles", async (ISender sender) =>
        {
            var r = await sender.Send(new GetAdminRolesQuery());
            return Api.Ok(r);
        })
        .WithName("GetAdminRoles")
        .Produces<ApiResponse<List<RoleDto>>>(StatusCodes.Status200OK);

        // GET /admin/roles/:id
        group.MapGet("/roles/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new GetRoleDetailsQuery(id));
            if (r == null) return Api.Fail("Role not found", 404);
            return Api.Ok(r);
        })
        .WithName("GetRoleDetails")
        .Produces<ApiResponse<RoleDetailsResponse>>(StatusCodes.Status200OK);

        // POST /admin/roles
        group.MapPost("/roles", async (CreateRoleCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Succeeded) return Api.Fail(r.Errors.FirstOrDefault() ?? "Failed", 400);
            return Api.Ok(r);
        })
        .WithName("CreateRole")
        .Produces<ApiResponse<Result>>(StatusCodes.Status200OK);

        // PUT /admin/roles/:id
        group.MapPut("/roles/{id:long}", async (long id, UpdateRoleCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { Id = id });
            if (!r.Succeeded) return Api.Fail(r.Errors.FirstOrDefault() ?? "Failed", 400);
            return Api.Ok(r);
        })
        .WithName("UpdateRole")
        .Produces<ApiResponse<Result>>(StatusCodes.Status200OK);

        // DELETE /admin/roles/:id
        group.MapDelete("/roles/{id:long}", async (long id, ISender sender) =>
        {
            var r = await sender.Send(new DeleteRoleCommand(id));
            if (!r.Succeeded) return Api.Fail(r.Errors.FirstOrDefault() ?? "Failed", 400);
            return Api.Ok(r);
        })
        .WithName("DeleteRole")
        .Produces<ApiResponse<Result>>(StatusCodes.Status200OK);

        // GET /admin/permissions
        group.MapGet("/permissions", async (ISender sender) =>
        {
            var r = await sender.Send(new GetAvailablePermissionsQuery());
            return Api.Ok(r);
        })
        .WithName("GetAvailablePermissions")
        .Produces<ApiResponse<List<PermissionMetadataDto>>>(StatusCodes.Status200OK);
    }
}
