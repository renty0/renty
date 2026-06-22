using Application.Features.Rentals;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class RentalEndpoints
{
    public static void MapRentalEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/rentals").WithTags("Rentals");

        // POST /rentals
        g.MapPost("/", async (CreateRentalRequest req, ISender sender) =>
        {
            var cmd = new CreateRentalCommand(req.ItemId, req.StartDate, req.EndDate, req.PricingType, req.Notes, req.RequestExpertReview);
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Created(new RentalCreateData(r.RentalId, r.OrderId, r.RentalPrice, r.DepositAmount, r.Status));
        })
        .WithName("CreateRental")
        .Produces<ApiResponse<RentalCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization();

        // GET /rentals
        g.MapGet("/", async (
            [Microsoft.AspNetCore.Mvc.FromQuery] string? status,
            [Microsoft.AspNetCore.Mvc.FromQuery] string? role,
            [Microsoft.AspNetCore.Mvc.FromQuery] int page,
            [Microsoft.AspNetCore.Mvc.FromQuery] int limit,
            ISender sender) =>
        {
            var r = await sender.Send(new GetRentalsQuery(status, page < 1 ? 1 : page, limit < 1 ? 20 : limit, role));
            return Api.Ok(r);
        })
        .WithName("GetRentals")
        .Produces<ApiResponse<Application.Features.Rentals.GetRentalsResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization(Policies.NonExpert);

        // GET /rentals/:id
        g.MapGet("/{id:guid}", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetRentalByIdQuery(id));
            if (!r.Found) return r.Error == "Forbidden." ? Api.Fail("Forbidden", 403) : Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r.Rental);
        })
        .WithName("GetRentalById")
        .Produces<ApiResponse<RentalDetailDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.NonExpert);

        // PUT /rentals/:id/confirm
        g.MapPut("/{id:guid}/confirm", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new ConfirmRentalCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new RentalStatusData(r.Status));
        })
        .WithName("ConfirmRental")
        .Produces<ApiResponse<RentalStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/handoff
        g.MapPut("/{id:guid}/handoff", async (Guid id, [Microsoft.AspNetCore.Mvc.FromBody] SetHandoffMethodBody body, ISender sender) =>
        {
            if (!Enum.TryParse<Domain.Enums.DeliveryMethod>(body.HandoffMethod, true, out var method))
                return Api.Fail("Invalid handoff method");
            var r = await sender.Send(new SetHandoffMethodCommand(id, method));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new RentalStatusData(r.Status));
        })
        .WithName("SetHandoffMethod")
        .Produces<ApiResponse<RentalStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // POST /rentals/:id/transfers/generate
        g.MapPost("/{id:guid}/transfers/generate", async (Guid id, [Microsoft.AspNetCore.Mvc.FromQuery] string? method, ISender sender) =>
        {
            var deliveryMethod = Enum.TryParse<Domain.Enums.DeliveryMethod>(method, true, out var parsedMethod) ? parsedMethod : Domain.Enums.DeliveryMethod.ByHand;
            var r = await sender.Send(new Application.Features.Transfers.GenerateHandoffTransfersCommand(id, deliveryMethod));
            if (!r) return Api.Fail("Failed to generate transfers. They might already exist.");
            return Api.Ok(new { Success = true });
        })
        .WithName("GenerateTransfers")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);

        // POST /rentals/:id/transfers/handoff-from-hub
        g.MapPost("/{id:guid}/transfers/handoff-from-hub", async (Guid id, [Microsoft.AspNetCore.Mvc.FromQuery] string? method, ISender sender) =>
        {
            var deliveryMethod = Enum.TryParse<Domain.Enums.DeliveryMethod>(method, true, out var parsedMethod) ? parsedMethod : Domain.Enums.DeliveryMethod.ByHand;
            var r = await sender.Send(new Application.Features.Transfers.GenerateHandoffFromHubTransfersCommand(id, deliveryMethod));
            if (!r) return Api.Fail("Failed to generate transfers. They might already exist or expert review is pending.");
            return Api.Ok(new { Success = true });
        })
        .WithName("GenerateHandoffFromHubTransfers")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // POST /rentals/:id/transfers/expert-return
        g.MapPost("/{id:guid}/transfers/expert-return", async (Guid id, [Microsoft.AspNetCore.Mvc.FromQuery] string? method, ISender sender) =>
        {
            var deliveryMethod = Enum.TryParse<Domain.Enums.DeliveryMethod>(method, true, out var parsedMethod) ? parsedMethod : Domain.Enums.DeliveryMethod.ByHand;
            var r = await sender.Send(new Application.Features.Transfers.GenerateExpertToOwnerTransfersCommand(id, deliveryMethod));
            if (!r) return Api.Fail("Failed to generate transfers. They might already exist or item is not with expert.");
            return Api.Ok(new { Success = true });
        })
        .WithName("GenerateExpertToOwnerTransfers")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);
        // PUT /rentals/:id/verify-transfer
        g.MapPut("/{id:guid}/verify-transfer", async (Guid id, [Microsoft.AspNetCore.Mvc.FromBody] string code, ISender sender) =>
        {
            var r = await sender.Send(new Application.Features.Transfers.VerifyTransferCommand(id, code));
            if (!r.Success) return Api.Fail(r.Error ?? "Invalid verification code or transfer not active.");
            return Api.Ok(new { Success = true });
        })
        .WithName("VerifyTransfer")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // POST /rentals/:id/photos
        g.MapPost("/{id:guid}/photos", async (Guid id, UploadRentalPhotosBody body, ISender sender) =>
        {
            var cmd = new UploadRentalPhotosCommand(id, body.ImageIds, body.Type);
            var success = await sender.Send(cmd);
            return success ? Api.Ok(new { }) : Api.Fail("Failed to upload photos", 400);
        })
        .WithName("UploadRentalPhotos")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // DELETE /rentals/:id/photos?imageUrl=...
        g.MapDelete("/{id:guid}/photos", async (Guid id, [Microsoft.AspNetCore.Mvc.FromQuery] string imageUrl, ISender sender) =>
        {
            var cmd = new DeleteRentalPhotoCommand(id, imageUrl);
            var success = await sender.Send(cmd);
            return success ? Api.Ok(new { }) : Api.Fail("Failed to delete photo", 400);
        })
        .WithName("DeleteRentalPhoto")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/complete
        g.MapPut("/{id:guid}/complete", async (Guid id,
            [Microsoft.AspNetCore.Mvc.FromQuery] bool damaged,
            ISender sender) =>
        {
            var r = await sender.Send(new CompleteRentalCommand(id, damaged));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new RentalCompleteData(r.RentalId, r.Status, r.LateFee, r.DepositStatus));
        })
        .WithName("CompleteRental")
        .Produces<ApiResponse<RentalCompleteData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/request-expert
        g.MapPut("/{id:guid}/request-expert", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new RequestExpertReviewCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { r.Success });
        })
        .WithName("RequestExpertReview")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);
        
        // DELETE /rentals/:id/request-expert
        g.MapDelete("/{id:guid}/request-expert", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new CancelExpertReviewCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { r.Success });
        })
        .WithName("CancelExpertReview")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/cancel
        g.MapPut("/{id:guid}/cancel", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new CancelRentalCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new RentalStatusData(r.Status));
        })
        .WithName("CancelRental")
        .Produces<ApiResponse<RentalStatusData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // POST /rentals/:id/dispute
        g.MapPost("/{id:guid}/dispute", async (Guid id, OpenDisputeBody body, ISender sender) =>
        {
            var cmd = new Application.Features.Disputes.OpenDisputeCommand(id, body.ReasonType, body.Description, body.MediaUrls);
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { Success = true });
        })
        .WithName("OpenRentalDispute")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/possession
        g.MapPut("/{id:guid}/possession", async (
            Guid id,
            [Microsoft.AspNetCore.Mvc.FromQuery] string action,
            [Microsoft.AspNetCore.Mvc.FromQuery] string method,
            ISender sender) =>
        {
            if (action == "initiate_return")
            {
                if (!Enum.TryParse<Domain.Enums.DeliveryMethod>(method, true, out var returnMethod))
                    return Api.Fail("Invalid delivery method");
                var result = await sender.Send(new Application.Features.Transfers.GenerateReturnTransfersCommand(id, returnMethod));
                return result ? Api.Ok(new { Success = true }) : Api.Fail("Failed to generate return transfers.");
            }
            var r = await sender.Send(new UpdatePossessionCommand(id, action, method));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { r.Success, r.Status });
        })
        .WithName("UpdatePossession")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // POST /rentals/:id/extend — Renter requests extension
        g.MapPost("/{id:guid}/extend", async (Guid id, ExtendRentalBody body, ISender sender) =>
        {
            var r = await sender.Send(new RequestExtensionCommand(id, body.ExtraDays));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Created(new { r.ExtensionId, r.NewEndDate, r.ExtraCost });
        })
        .WithName("RequestRentalExtension")
        .Produces<ApiResponse<object>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // PUT /rentals/:id/extend/:extId/respond — Owner approves/rejects
        g.MapPut("/{id:guid}/extend/{extId:guid}/respond", async (Guid id, Guid extId, RespondExtensionBody body, ISender sender) =>
        {
            var r = await sender.Send(new RespondToExtensionCommand(id, extId, body.Approve));
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { r.Status, r.NewEndDate });
        })
        .WithName("RespondToExtension")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);
    }
}

public record CreateRentalRequest(
    Guid ItemId,
    DateTime StartDate,
    DateTime EndDate,
    string PricingType = "daily",
    string? Notes = null,
    bool RequestExpertReview = false
);

public record SetHandoffMethodBody(string HandoffMethod);
public record InitiateReturnBody(string ReturnMethod);
public record ExtendRentalBody(int ExtraDays);
public record RespondExtensionBody(bool Approve);
public record OpenDisputeBody(string ReasonType, string Description, List<string>? MediaUrls);
