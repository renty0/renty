using Application.Web.MediaFiles.Commands.UploadMedia;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Web.Responses;

namespace Web.Endpoints;

public static class MediaEndpoints
{
    public static void MapMediaEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/media")
            .WithTags("Media")
            .RequireAuthorization()
            .DisableAntiforgery();

        group.MapPost("/", async (
            IFormFile? file,
            [FromForm] Guid? entityId,
            [FromForm] string? entityType,
            ISender sender) =>
        {
            if (file is null || file.Length == 0)
                return Api.Fail("A file is required.");

            const long maxBytes = 20 * 1024 * 1024;
            if (file.Length > maxBytes)
                return Api.Fail("File exceeds the 20 MB limit.");

            var allowed = new[] { "image/", "video/", "audio/", "application/pdf" };
            if (!allowed.Any(p => file.ContentType.StartsWith(p, StringComparison.OrdinalIgnoreCase)))
                return Api.Fail("Unsupported file type.");

            var result = await sender.Send(new UploadMediaCommand
            {
                File = file,
                TenantId = null,
                TenantType = null
            });

            var data = new MediaUploadData(
                result.Id, result.Url, result.OriginalFileName, result.FileExtension,
                result.ContentType, result.FileType, result.FileSize,
                result.Width, result.Height, result.CreatedAt,
                entityId, entityType);

            return Api.Created(data);
        })
        .WithName("UploadMedia")
        .Produces<ApiResponse<MediaUploadData>>(StatusCodes.Status201Created)
        .Produces<ApiResponse<object>>(StatusCodes.Status400BadRequest)
        .Accepts<IFormFile>("multipart/form-data");
    }
}
