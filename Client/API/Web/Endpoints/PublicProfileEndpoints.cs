using Application.Features.PublicProfile;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class PublicProfileEndpoints
{
    public static void MapPublicProfileEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/public-profile").WithTags("Public Profile");

        g.MapGet("/{userId:long}", async (long userId, ISender sender) =>
        {
            var r = await sender.Send(new GetPublicProfileQuery(userId));
            if (!r.Success) return Api.Fail(r.Error ?? "User not found", 404);
            return Api.Ok(r.Profile);
        })
        .WithName("GetPublicProfile")
        .Produces<ApiResponse<PublicProfileDto>>(StatusCodes.Status200OK)
        .AllowAnonymous();
    }
}
