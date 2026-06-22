using Application.Features.Support;
using MediatR;
using Microsoft.AspNetCore.Http;

namespace Web.Endpoints;

public static class TestEndpoints
{
    public static void MapTestEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/test-tickets", async (ISender sender) =>
        {
            var r = await sender.Send(new GetTicketsQuery(true)); // Simulate Admin
            return Results.Ok(r);
        })
        .AllowAnonymous();
    }
}
