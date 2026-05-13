using Domain.Constants;

namespace Web;

public static class Roles
{
    public const string User       = Domain.Constants.Roles.User;
    public const string Admin      = Domain.Constants.Roles.Admin;
    public const string Support    = Domain.Constants.Roles.Support;
    public const string SuperAdmin = Domain.Constants.Roles.SuperAdmin;
    public const string Expert     = Domain.Constants.Roles.Expert;
}

public static class Policies
{
    public const string AdminAccess     = Domain.Constants.Policies.AdminAccess;
    public const string SuperAdminOnly  = Domain.Constants.Policies.SuperAdminOnly;
    public const string SupportAccess   = Domain.Constants.Policies.SupportAccess;
    public const string ExpertAccess    = Domain.Constants.Policies.ExpertAccess;
    public const string NonExpert       = Domain.Constants.Policies.NonExpert;
    public const string CanTransact     = Domain.Constants.Policies.CanTransact;
    public const string ExpertOrAdmin   = Domain.Constants.Policies.ExpertOrAdmin;
}
