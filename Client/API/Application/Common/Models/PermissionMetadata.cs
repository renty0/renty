namespace Application.Common.Models;

public record PermissionMetadataDto(
    string Module,
    List<PermissionItemDto> Permissions
);

public record PermissionItemDto(
    string Value,
    string Label,
    string[] AllowedRoles
);
