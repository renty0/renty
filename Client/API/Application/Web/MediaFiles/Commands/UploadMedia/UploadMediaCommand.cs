using Domain.Entities;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Rently.API.Application.Shared.Attributes;
using Application.Web.MediaFiles.DTOs;
using Application.Common.Interfaces;
using Ardalis.GuardClauses;
using SixLabors.ImageSharp;

namespace Application.Web.MediaFiles.Commands.UploadMedia;

public class FileUploadSettings
{
    public string UploadPath { get; set; } = "uploads";
}

/// <summary>
/// Command for uploading media files to local storage
/// Images are automatically optimized
/// </summary>
[Endpoint(EndpointMethod.Post, "MediaFiles")]
public record UploadMediaCommand : IRequest<MediaFileDto>
{
    /// <summary>
    /// The file to upload
    /// </summary>
    public IFormFile File { get; init; } = null!;

    /// <summary>
    /// Optional tenant ID to associate the file with
    /// </summary>
    public int? TenantId { get; init; }

    /// <summary>
    /// Optional tenant type to associate the file with
    /// </summary>
    public int? TenantType { get; init; }
}

public sealed class UploadMediaCommandHandler : IRequestHandler<UploadMediaCommand, MediaFileDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly ILogger<UploadMediaCommandHandler> _logger;
    private readonly string _uploadsPath;

    public UploadMediaCommandHandler(
        IApplicationDbContext context,
        IUser currentUser,
        IOptions<FileUploadSettings> settings,
        ILogger<UploadMediaCommandHandler> logger)
    {
        _context = context;
        _currentUser = currentUser;
        _logger = logger;
        
        // Get uploads path from configuration
        _uploadsPath = settings.Value.UploadPath;
        
        // Ensure the directory exists
        if (!Path.IsPathRooted(_uploadsPath))
        {
            // If relative path, make it absolute relative to current directory
            _uploadsPath = Path.GetFullPath(_uploadsPath);
        }
        Directory.CreateDirectory(_uploadsPath);
    }

    public async Task<MediaFileDto> Handle(UploadMediaCommand request, CancellationToken cancellationToken)
    {
        var file = request.File;
        Guard.Against.Null(file);

        var fileId = Guid.NewGuid();
        var fileName = file.FileName;
        var contentType = file.ContentType;
        var originalSize = file.Length;
        var extension = Path.GetExtension(fileName);
        var fileType = DetermineFileType(contentType);

        // Create MediaFile entity
        var mediaFile = new MediaFile
        {
            Id = fileId,
            OriginalFileName = Path.GetFileNameWithoutExtension(fileName),
            FileExtension = extension,
            ContentType = contentType,
            FileSize = originalSize,
            FileType = fileType,
            StoragePath = string.Empty, // Will be set after upload
            CreatedBy = (int?)_currentUser.Id,
            CreatedAt = DateTime.UtcNow,
            TenantId = request.TenantId ?? 0,
            TenantType = request.TenantType ?? 0
        };

        try
        {
            // Determine folder based on file type
            var folder = GetFolderForFileType(fileType);
            var folderPath = Path.Combine(_uploadsPath, folder);
            Directory.CreateDirectory(folderPath);

            // Generate unique filename
            var uniqueFileName = $"{fileId}{extension}";
            var filePath = Path.Combine(folderPath, uniqueFileName);

            // Save file to disk
            await using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream, cancellationToken);
            }

            // Set storage path (relative to uploads folder)
            mediaFile.StoragePath = Path.Combine(folder, uniqueFileName).Replace("\\", "/");

            // For images, try to get dimensions
            if (fileType == FileType.Image)
            {
                try
                {
                    using var image = await Image.LoadAsync(filePath, cancellationToken);
                    mediaFile.Width = image.Width;
                    mediaFile.Height = image.Height;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to read image dimensions for {FileName}", fileName);
                }
            }

            _context.MediaFiles.Add(mediaFile);
            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation(
                "Uploaded media file {FileName} (ID: {Id}). Type: {FileType}, Size: {Size} bytes",
                fileName, mediaFile.Id, fileType, originalSize);

            return mediaFile.ToDto();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to upload media file {FileName}", fileName);
            throw new InvalidOperationException($"Failed to upload media file '{fileName}'", ex);
        }
    }

    private static FileType DetermineFileType(string contentType)
    {
        if (contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
            return FileType.Image;

        if (contentType.StartsWith("video/", StringComparison.OrdinalIgnoreCase))
            return FileType.Video;

        if (contentType.StartsWith("audio/", StringComparison.OrdinalIgnoreCase))
            return FileType.Audio;

        return FileType.Document;
    }

    private static string GetFolderForFileType(FileType fileType)
    {
        return fileType switch
        {
            FileType.Image => "images",
            FileType.Video => "videos",
            FileType.Audio => "audio",
            FileType.Document => "documents",
            _ => "files"
        };
    }
}
