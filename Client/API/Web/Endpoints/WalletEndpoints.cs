using Application.Features.Wallets;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class WalletEndpoints
{
    public static void MapWalletEndpoints(this IEndpointRouteBuilder app)
    {
        // GET /wallet/balance
        app.MapGet("/api/v1/wallet/balance", async (ISender sender) =>
        {
            var r = await sender.Send(new GetWalletBalanceQuery());
            if (!r.Success) return Api.Fail(r.Error ?? "Unauthorized", 401);
            return Api.Ok(new { r.Balance });
        })
        .WithTags("Wallet").WithName("GetWalletBalance")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        // GET /wallet/transactions
        app.MapGet("/api/v1/wallet/transactions", async (ISender sender) =>
        {
            var r = await sender.Send(new GetWalletTransactionsQuery());
            if (!r.Success) return Api.Fail(r.Error ?? "Unauthorized", 401);
            return Api.Ok(r.Transactions);
        })
        .WithTags("Wallet").WithName("GetWalletTransactions")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        // POST /wallet/withdraw
        app.MapPost("/api/v1/wallet/withdraw", async (RequestWithdrawalCommand cmd, ISender sender) =>
        {
            var r = await sender.Send(cmd);
            if (!r.Success) return Api.Fail(r.Error ?? "Bad request", 400);
            return Api.Ok(new { message = "Withdrawal requested successfully." });
        })
        .WithTags("Wallet").WithName("RequestWithdrawal")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .RequireAuthorization();
    }
}
