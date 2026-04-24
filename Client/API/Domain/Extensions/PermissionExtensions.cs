using Domain.Enums;
using System.Reflection;
using System.Runtime.Serialization;

namespace Domain.Extensions;

public static class PermissionExtensions
{
    public static string ToPermissionString(this PermissionType permission)
    {
        var type = typeof(PermissionType);
        var name = Enum.GetName(type, permission);
        if (name == null) return string.Empty;

        var field = type.GetField(name);
        var attribute = field?.GetCustomAttribute<EnumMemberAttribute>();

        return attribute?.Value ?? name;
    }

    public static string GetModule(this PermissionType permission)
    {
        var permissionString = permission.ToPermissionString();
        // Format is "Permissions.Module.Action"
        var parts = permissionString.Split('.');
        return parts.Length >= 2 ? parts[1] : "General";
    }
}
