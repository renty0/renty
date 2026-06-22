using System.ComponentModel.DataAnnotations.Schema;

namespace Domain.Entities;

public class MediaFile
{
    public Guid Id { get; set; }

    /// <summary>
    /// The local file path relative to wwwroot (e.g., "uploads/images/guid.jpg")
    /// </summary>
    public string StoragePath { get; set; } = string.Empty;

    public FileType FileType { get; set; }
    public string OriginalFileName { get; set; } = string.Empty;
    public string FileExtension { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public long FileSize { get; set; }

    /// <summary>
    /// Image width in pixels (for images only)
    /// </summary>
    public int? Width { get; set; }

    /// <summary>
    /// Image height in pixels (for images only)
    /// </summary>
    public int? Height { get; set; }

    public int? CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int TenantId { get; set; }
    public int TenantType { get; set; }

    [NotMapped]
    public bool ManageTenantManually { get; set; }

    public void SetTenant(int tenantId, int tenantType)
    {
        TenantId = tenantId;
        TenantType = tenantType;
        ManageTenantManually = true;
    }

    public bool HasTenant() => TenantId != 0 && TenantType != 0;

    /// <summary>
    /// Gets the full public URL for the file
    /// </summary>
    public string GetFullUrl(string baseUrl)
    {
        if (string.IsNullOrEmpty(StoragePath))
            return string.Empty;

        if (StoragePath.StartsWith("http://") || StoragePath.StartsWith("https://"))
            return StoragePath;

        return $"{baseUrl?.TrimEnd('/')}/{StoragePath}";
    }
}

public enum FileType
{
    Unknown = 0,
    Image = 1,
    Document = 2,
    Video = 3,
    Audio = 4
}
