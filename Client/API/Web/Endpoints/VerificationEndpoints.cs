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

        // ── USER IDENTITY VERIFICATIONS ──

        // POST /user/phone/request
        app.MapPost("/api/v1/user/phone/request", async (RequestPhoneVerificationCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new { r.SimulatedOtp });
        })
        .WithTags("Identity").WithName("RequestPhoneVerification")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .RequireAuthorization();

        // POST /user/phone/confirm
        app.MapPost("/api/v1/user/phone/confirm", async (ConfirmPhoneVerificationCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new { message = "Phone verified successfully." });
        })
        .WithTags("Identity").WithName("ConfirmPhoneVerification")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        // POST /user/id/upload
        app.MapPost("/api/v1/user/id/upload", async (UploadIdVerificationCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new { r.IdVerificationId });
        })
        .WithTags("Identity").WithName("UploadIdVerification")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .RequireAuthorization();

        // POST /admin/id-verifications/{id}/review
        app.MapPost("/api/v1/admin/id-verifications/{id:guid}/review", async (Guid id, ReviewIdVerificationCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { IdVerificationId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new { message = "Review processed" });
        })
        .WithTags("Identity").WithName("ReviewIdVerification")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
