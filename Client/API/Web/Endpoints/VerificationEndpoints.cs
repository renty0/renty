using Application.Features.Verifications;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class VerificationEndpoints
{
    public static void MapVerificationEndpoints(this IEndpointRouteBuilder app)
    {
        // POST /items/:id/verify
        app.MapPost("/api/v1/items/{id:guid}/verify", async (Guid id, CreateVerificationCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { ItemId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new VerificationCreateData(r.VerificationId, r.Status));
        })
        .WithTags("Verifications").WithName("CreateVerification")
        .Produces<ApiResponse<VerificationCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.ExpertOrAdmin);

        // GET /items/:id/verifications
        app.MapGet("/api/v1/items/{id:guid}/verifications", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetVerificationsQuery(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r);
        })
        .WithTags("Verifications").WithName("GetVerifications")
        .Produces<ApiResponse<GetVerificationsResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization();

        // GET /expert/assigned
        app.MapGet("/api/v1/expert/assigned", async (ISender sender) =>
        {
            var r = await sender.Send(new GetExpertAssignedQuery());
            return Api.Ok(r);
        })
        .WithTags("Verifications").WithName("GetExpertAssigned")
        .Produces<ApiResponse<GetExpertAssignedResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.ExpertAccess);
    }
}
