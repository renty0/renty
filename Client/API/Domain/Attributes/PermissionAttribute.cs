namespace Domain.Attributes;

[AttributeUsage(AttributeTargets.Field, AllowMultiple = false)]
public class PermissionAttribute : Attribute
{
    public string Module { get; }
    public string Action { get; }
    public string[] Roles { get; }

    public PermissionAttribute(string module, string action, params string[] roles)
    {
        Module = module;
        Action = action;
        Roles = roles;
    }
}
