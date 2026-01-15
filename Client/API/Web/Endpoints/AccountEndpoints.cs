using Application.Web.Account;
using MediatR;

namespace Web.Endpoints;

public static class AccountEndpoints
{
    public static void MapAccountEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/account")
            .WithTags("Account");

        group.MapPost("/register", async (RegisterCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("Register")
        .Produces<RegisterResponse>(StatusCodes.Status200OK)
        .Produces<RegisterResponse>(StatusCodes.Status400BadRequest)
        .WithOpenApi()
        .AllowAnonymous();

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
        .Produces<LoginResponse>(StatusCodes.Status200OK)
        .Produces<LoginResponse>(StatusCodes.Status400BadRequest)
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
        .Produces<RefreshTokenResponse>(StatusCodes.Status200OK)
        .Produces<RefreshTokenResponse>(StatusCodes.Status400BadRequest)
        .WithOpenApi()
        .AllowAnonymous();

        group.MapPost("/logout", async (LogoutCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return Results.Ok(result);
        })
        .WithName("Logout")
        .Produces<LogoutResponse>(StatusCodes.Status200OK)
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
        .Produces<GetCurrentUserResponse>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status401Unauthorized)
        .WithOpenApi()
        .RequireAuthorization();

        group.MapPut("/profile", async (UpdateUserCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Success)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("UpdateProfile")
        .Produces<UpdateUserResponse>(StatusCodes.Status200OK)
        .Produces<UpdateUserResponse>(StatusCodes.Status400BadRequest)
        .WithOpenApi()
        .RequireAuthorization();

        group.MapPost("/send-email-confirmation", async (SendEmailConfirmationCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Succeeded)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("SendEmailConfirmation")
        .Produces<Application.Common.Models.Result>(StatusCodes.Status200OK)
        .Produces<Application.Common.Models.Result>(StatusCodes.Status400BadRequest)
        .WithOpenApi()
        .AllowAnonymous(); // Allow anonymous so unverified users can request it

        group.MapPost("/confirm-email", async (ConfirmEmailCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            if (!result.Succeeded)
            {
                return Results.BadRequest(result);
            }
            return Results.Ok(result);
        })
        .WithName("ConfirmEmail")
        .Produces<Application.Common.Models.Result>(StatusCodes.Status200OK)
        .Produces<Application.Common.Models.Result>(StatusCodes.Status400BadRequest)
        .WithOpenApi()
        .AllowAnonymous();
    }
}
