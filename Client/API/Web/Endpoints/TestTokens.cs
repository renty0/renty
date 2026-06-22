using Application.Common.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Web.Endpoints;

public static class TestTokens
{
    public static void MapTestTokens(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/test-token", async (IIdentityService identity, ITokenService tokenService) =>
        {
            var user = await identity.GetUserByEmailAsync("admin@renty.com");
            if (user == null) return Results.NotFound();
            var token = await tokenService.GenerateTokensAsync(user.Id);
            return Results.Ok(token.AccessToken);
        })
        .AllowAnonymous();
    }
}
