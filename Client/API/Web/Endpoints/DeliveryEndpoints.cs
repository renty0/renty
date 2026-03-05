using Application.Features.Delivery;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class DeliveryEndpoints
{
    public static void MapDeliveryEndpoints(this IEndpointRouteBuilder app)
    {
        // GET /orders/:id/delivery
        app.MapGet("/api/v1/orders/{id:guid}/delivery", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new GetDeliveryQuery(id));
            if (!r.Found) return r.Error == "Forbidden." ? Api.Fail("Forbidden", 403) : Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r.Tracking);
        })
        .WithTags("Delivery").WithName("GetDelivery")
        .Produces<ApiResponse<List<TrackingEntryDto>>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.NonExpert);

        // PUT /orders/:id/delivery
        app.MapPut("/api/v1/orders/{id:guid}/delivery", async (Guid id, UpdateDeliveryCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd with { OrderId = id });
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Ok(new { message = "Delivery status updated" });
        })
        .WithTags("Delivery").WithName("UpdateDelivery")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.AdminAccess);
    }
}
