using System;

namespace Application.Common;

public static class UrlExtensions
{
    public static string? ToAbsoluteUrl(this string? path, string? baseUrl)
    {
        if (string.IsNullOrEmpty(path))
            return null;

        if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
            path.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            return path;
        }

        return $"{baseUrl?.TrimEnd('/')}/{path.Replace("\\", "/").TrimStart('/')}";
    }
}
