namespace Application.Web.MediaFiles.DTOs;

public record MediaFileDto
{
    public Guid Id { get; init; }
    public string OriginalFileName { get; init; } = string.Empty;
    public string FileExtension { get; init; } = string.Empty;
    public string ContentType { get; init; } = string.Empty;
    public long FileSize { get; init; }
    public string FileType { get; init; } = string.Empty;
    public string Url { get; init; } = string.Empty;
    public int? Width { get; init; }
    public int? Height { get; init; }
    public DateTime CreatedAt { get; init; }
}

public static class MediaFileExtensions
{
    public static MediaFileDto ToDto(this Domain.Entities.MediaFile mediaFile, string? baseUrl = null)
    {
        // Use the request base URL or a default
        var url = string.Empty;
        if (!string.IsNullOrEmpty(mediaFile.StoragePath) && 
            (mediaFile.StoragePath.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
             mediaFile.StoragePath.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
        {
            url = mediaFile.StoragePath;
        }
        else
        {
            url = !string.IsNullOrEmpty(baseUrl) 
                ? mediaFile.GetFullUrl(baseUrl)
                : $"/{mediaFile.StoragePath}";
        }

        return new MediaFileDto
        {
            Id = mediaFile.Id,
            OriginalFileName = mediaFile.OriginalFileName,
            FileExtension = mediaFile.FileExtension,
            ContentType = mediaFile.ContentType,
            FileSize = mediaFile.FileSize,
            FileType = mediaFile.FileType.ToString(),
            Url = url,
            Width = mediaFile.Width,
            Height = mediaFile.Height,
            CreatedAt = mediaFile.CreatedAt
        };
    }
}
