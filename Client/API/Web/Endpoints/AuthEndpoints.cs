using Application.Web.Account;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/auth").WithTags("Auth");

        // POST /auth/register
        group.MapPost("/register", async (RegisterCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            if (!r.Success)
                return r.Message != null && r.Message.Contains("already registered")
                    ? Api.Fail("Email already registered", 409)
                    : Api.Fail(r.Message ?? "Bad request");

            return Api.Created(new AuthRegisterData("Registration successful.", r.User?.Id));
        })
        .WithName("AuthRegister")
        .Produces<ApiResponse<AuthRegisterData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        // POST /auth/verify-email
        group.MapPost("/verify-email", async (ConfirmEmailCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            if (!r.Succeeded)
                return Api.Fail(r.Errors.FirstOrDefault() ?? "Verification failed");
            return Api.Ok(new AuthVerifyEmailData("Email verified"));
        })
        .WithName("AuthVerifyEmail")
        .Produces<ApiResponse<AuthVerifyEmailData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        // POST /auth/send-verification
        group.MapPost("/send-verification", async (SendEmailConfirmationCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            if (!r.Succeeded)
                return Api.Fail(r.Errors.FirstOrDefault() ?? "Failed to send verification email");
            return Api.Ok(new { message = "Verification email sent successfully." });
        })
        .WithName("AuthSendVerification")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .AllowAnonymous();

        // POST /auth/login
        group.MapPost("/login", async (LoginCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            if (!r.Success)
                return Api.Fail("Invalid credentials", 401);

            var data = new AuthLoginData(
                r.Token?.AccessToken,
                r.Token?.RefreshToken,
                r.Token?.RefreshTokenExpiresAt,
                r.User == null ? null : new AuthLoginUser(
                    r.User.Id, r.User.FirstName, r.User.LastName,
                    r.User.Email, r.User.Roles?.FirstOrDefault(),
                    r.User.ProfilePictureUrl));

            return Api.Ok(data);
        })
        .WithName("AuthLogin")
        .Produces<ApiResponse<AuthLoginData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status401Unauthorized)
        .AllowAnonymous();

        // POST /auth/refresh
        group.MapPost("/refresh", async (RefreshTokenCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            if (!r.Success)
                return Api.Fail(r.Message ?? "Invalid token", 401);
            return Api.Ok(new AuthRefreshData(r.Token?.AccessToken, r.Token?.RefreshToken));
        })
        .WithName("AuthRefresh")
        .Produces<ApiResponse<AuthRefreshData>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status401Unauthorized)
        .AllowAnonymous();

        // GET /auth/me
        group.MapGet("/me", async (ISender sender) =>
        {
            var r = await sender.Send(new GetCurrentUserQuery());
            if (!r.Success) return Api.Fail("Unauthorized", 401);
            var u = r.User!;
            return Api.Ok(new AuthMeData(
                u.Id, u.FirstName, u.LastName, u.Email, u.PhoneNumber, u.City,
                u.Roles?.FirstOrDefault(), u.ProfilePictureUrl, u.IsVerified,
                u.CreatedAt.DateTime));
        })
        .WithName("AuthMe")
        .Produces<ApiResponse<AuthMeData>>(StatusCodes.Status200OK)
        .RequireAuthorization();

        // PUT /auth/me
        group.MapPut("/me", async (UpdateUserCommand command, ISender sender) =>
        {
            var r = await sender.Send(command);
            if (!r.Success) return Api.Fail(r.Message ?? "Bad request");
            return Api.Ok(r.User);
        })
        .WithName("AuthUpdateMe")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .RequireAuthorization();
    }
}
