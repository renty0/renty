using Domain.Common;

namespace Domain.Entities;

public class Permission : BaseAuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Module { get; set; } = string.Empty;
    public string Action { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty; // e.g. Permissions.Items.View
}
