using FluentValidation;

namespace Application.Web.MediaFiles.Commands.UploadMedia;

public class UploadMediaCommandValidator : AbstractValidator<UploadMediaCommand>
{
    private const long MaxFileSize = 10 * 1024 * 1024; // 10MB
    
    private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
    private static readonly string[] AllowedDocumentExtensions = { ".pdf", ".doc", ".docx", ".txt" };
    private static readonly string[] AllowedVideoExtensions = { ".mp4", ".avi", ".mov", ".wmv", ".webm" };
    private static readonly string[] AllowedAudioExtensions = { ".mp3", ".wav", ".ogg", ".webm", ".m4a" };

    public UploadMediaCommandValidator()
    {
        RuleFor(x => x.File)
            .NotNull().WithMessage("File is required")
            .Must(file => file.Length > 0).WithMessage("File cannot be empty")
            .Must(file => file.Length <= MaxFileSize).WithMessage($"File size cannot exceed {MaxFileSize / 1024 / 1024}MB")
            .Must(HaveValidExtension).WithMessage("File type is not allowed");
    }

    private bool HaveValidExtension(Microsoft.AspNetCore.Http.IFormFile file)
    {
        if (file == null) return false;

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        
        return AllowedImageExtensions.Contains(extension) ||
               AllowedDocumentExtensions.Contains(extension) ||
               AllowedVideoExtensions.Contains(extension) ||
               AllowedAudioExtensions.Contains(extension);
    }
}
