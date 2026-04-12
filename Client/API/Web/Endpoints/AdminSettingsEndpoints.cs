using Application.Features.AdminSettings;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AdminSettingsEndpoints
{
    public static void MapAdminSettingsEndpoints(this IEndpointRouteBuilder app)
    {
        // GET /admin/settings
        app.MapGet("/api/v1/admin/settings", async (ISender sender) =>
        {
            var r = await sender.Send(new GetSettingsQuery());
            return Api.Ok(r.Settings);
        })
        .WithTags("AdminSettings").WithName("GetAdminSettings")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);

        // POST /admin/settings
        app.MapPost("/api/v1/admin/settings", async (UpdateSettingCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { message = "Setting updated successfully." });
        })
        .WithTags("AdminSettings").WithName("UpdateAdminSetting")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
