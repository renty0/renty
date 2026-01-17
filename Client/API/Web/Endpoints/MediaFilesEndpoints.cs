using Application.Web.MediaFiles.DTOs;
using Application.Web.MediaFiles.Commands.UploadMedia;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace Web.Endpoints;

public static class MediaFilesEndpoints
{
    public static void MapMediaFilesEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/media-files")
            .WithTags("MediaFiles")
            .RequireAuthorization();

        group.MapPost("/", async (IFormFile file, [FromForm] int? tenantId, [FromForm] int? tenantType, ISender sender) =>
        {
            var result = await sender.Send(new UploadMediaCommand { 
                File = file, 
                TenantId = tenantId, 
                TenantType = tenantType 
            });
            return Results.Ok(result);
        })
        .WithName("UploadMedia")
        .Produces<MediaFileDto>(StatusCodes.Status200OK)
        .Accepts<IFormFile>("multipart/form-data")
        .WithOpenApi()
        .DisableAntiforgery();
    }
}
