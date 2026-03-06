using Application.Web.Account;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AccountEndpoints
{
    public static void MapAccountEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/account").WithTags("Account");

        group.MapPost("/register", async (RegisterCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Registration failed");
        })
        .WithName("Register")
        .Produces<ApiResponse<RegisterResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        group.MapPost("/login", async (LoginCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Login failed", 401);
        })
        .WithName("Login")
        .Produces<ApiResponse<LoginResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status401Unauthorized)
        .AllowAnonymous();

        group.MapPost("/refresh-token", async (RefreshTokenCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Invalid token", 401);
        })
        .WithName("RefreshToken")
        .Produces<ApiResponse<RefreshTokenResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status401Unauthorized)
        .AllowAnonymous();

        group.MapPost("/logout", async (LogoutCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return Api.Ok(result);
        })
        .WithName("Logout")
        .Produces<ApiResponse<LogoutResponse>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        group.MapGet("/me", async (ISender sender) =>
        {
            var result = await sender.Send(new GetCurrentUserQuery());
            return result.Success ? Api.Ok(result) : Api.Fail("Unauthorized", 401);
        })
        .WithName("GetCurrentUser")
        .Produces<ApiResponse<GetCurrentUserResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status401Unauthorized)
        .RequireAuthorization();

        group.MapPut("/profile", async (UpdateUserCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Success ? Api.Ok(result) : Api.Fail(result.Message ?? "Update failed");
        })
        .WithName("UpdateProfile")
        .Produces<ApiResponse<UpdateUserResponse>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization();

        group.MapPost("/send-email-confirmation", async (SendEmailConfirmationCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Succeeded ? Api.Ok(result) : Api.Fail(result.Errors.FirstOrDefault() ?? "Failed");
        })
        .WithName("SendEmailConfirmation")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        group.MapPost("/confirm-email", async (ConfirmEmailCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Succeeded ? Api.Ok(result) : Api.Fail(result.Errors.FirstOrDefault() ?? "Confirmation failed");
        })
        .WithName("ConfirmEmail")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        group.MapPost("/forgot-password", async (ForgotPasswordCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Succeeded ? Api.Ok(new { message = "Password reset code has been sent." }) : Api.Fail(result.Errors.FirstOrDefault() ?? "Failed");
        })
        .WithName("ForgotPassword")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        group.MapPost("/reset-password", async (ResetPasswordCommand command, ISender sender) =>
        {
            var result = await sender.Send(command);
            return result.Succeeded ? Api.Ok(new { message = "Password has been reset successfully." }) : Api.Fail(result.Errors.FirstOrDefault() ?? "Failed to reset password");
        })
        .WithName("ResetPassword")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();
    }
}
