using Application.Web.Account;
using MediatR;

namespace Web.Endpoints;

public static class AccountEndpoints
{
    public static void MapAccountEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/account")
            .WithTags("Account");

        group.MapPost("/login", async (LoginCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("Login")
        .WithOpenApi()
        .AllowAnonymous();

        group.MapPost("/refresh-token", async (RefreshTokenCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("RefreshToken")
        .WithOpenApi()
        .AllowAnonymous();

        group.MapPost("/logout", async (LogoutCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return Results.Ok(result);
        })
        .WithName("Logout")
        .WithOpenApi()
        .RequireAuthorization();

        group.MapGet("/me", async (ISender sender) =>
        {
            var result = await sender.Send(new GetCurrentUserQuery());
            if (!result.Success)
            {
                return Results.Unauthorized();
            }
            return Results.Ok(result);
        })
        .WithName("GetCurrentUser")
        .WithOpenApi()
        .RequireAuthorization();
    }
}
