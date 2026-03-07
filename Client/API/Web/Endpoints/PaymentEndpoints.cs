using Application.Features.Payments;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class PaymentEndpoints
{
    public static void MapPaymentEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/payments").WithTags("Payments");

        // POST /payments
        g.MapPost("/", async (CreatePaymentCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request");
            return Api.Created(new PaymentCreateData(r.PaymentId, r.Status, r.TransactionRef));
        })
        .WithName("CreatePayment")
        .Produces<ApiResponse<PaymentCreateData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization(Policies.CanTransact);

        // GET /payments/:orderId
        g.MapGet("/{orderId:guid}", async (Guid orderId, ISender sender) =>
        {
            var r = await sender.Send(new GetPaymentByOrderQuery(orderId));
            if (!r.Found) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(r.Payment);
        })
        .WithName("GetPaymentByOrder")
        .Produces<ApiResponse<PaymentDto>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound)
        .RequireAuthorization(Policies.CanTransact);
    }
}
