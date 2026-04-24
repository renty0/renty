using Domain.Common;

namespace Domain.Entities;

public class RolePermission : BaseAuditableEntity
{
    public long RoleId { get; set; }
    public string RoleName { get; set; } = string.Empty;

    /// <summary>
    /// The permission value string (e.g., "Permissions.Item.View")
    /// This corresponds to the PermissionType enum value
    /// </summary>
    public string PermissionValue { get; set; } = string.Empty;
}
