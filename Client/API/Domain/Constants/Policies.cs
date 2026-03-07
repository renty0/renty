namespace Domain.Constants;

public static class Policies
{
    public const string AdminAccess     = "AdminAccess";
    public const string SuperAdminOnly  = "SuperAdminOnly";
    public const string SupportAccess   = "SupportAccess";
    public const string ExpertAccess    = "ExpertAccess";
    public const string NonExpert       = "NonExpert";
    public const string CanTransact     = "CanTransact";
    public const string ExpertOrAdmin   = "ExpertOrAdmin";
}
