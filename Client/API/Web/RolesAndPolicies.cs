namespace Web;

/// <summary>
/// Central role name constants matching the spec's 5 roles.
/// Used in RequireAuthorization() and AddPolicy() calls.
/// </summary>
public static class Roles
{
    public const string User       = "user";
    public const string Admin      = "admin";
    public const string Support    = "support";
    public const string SuperAdmin = "super_admin";
    public const string Expert     = "expert";
}

/// <summary>Named authorization policy names.</summary>
public static class Policies
{
    /// <summary>admin OR super_admin</summary>
    public const string AdminAccess     = "AdminAccess";

    /// <summary>super_admin only</summary>
    public const string SuperAdminOnly  = "SuperAdminOnly";

    /// <summary>support OR admin OR super_admin</summary>
    public const string SupportAccess   = "SupportAccess";

    /// <summary>expert only</summary>
    public const string ExpertAccess    = "ExpertAccess";

    /// <summary>Any authenticated user (user / admin / support / super_admin) — NOT expert</summary>
    public const string NonExpert       = "NonExpert";

    /// <summary>user OR admin OR super_admin (not support, not expert)</summary>
    public const string CanTransact     = "CanTransact";

    /// <summary>expert OR admin OR super_admin</summary>
    public const string ExpertOrAdmin   = "ExpertOrAdmin";
}
