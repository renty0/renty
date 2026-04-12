using Application.Features.Disputes;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class DisputeEndpoints
{
    public static void MapDisputeEndpoints(this IEndpointRouteBuilder app)
    {
        // POST /admin/disputes/resolve
        app.MapPost("/api/v1/support/disputes/resolve", async (ResolveDisputeCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { message = "Dispute resolved successfully." });
        })
        .WithTags("Disputes").WithName("ResolveDispute")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess); // Admins and Support usually handle disputes
    }
}
