namespace Application.Common.Models;

public record VerificationDto(
    Guid Id, 
    string CheckType, 
    string Status, 
    string? Notes,
    string? ExpertFirstName, 
    DateTime CreatedAt,
    string? VerificationCode
);

public record PersonInfoDto(string FullName, string? Phone, string? ProfilePicture);

public record RentalInfoDto(
    Guid RentalId,
    DateTime StartDate, DateTime EndDate,
    decimal RentalPrice, decimal DepositAmount,
    string Status,
    PersonInfoDto Renter,
    string CurrentPossession,
    bool HasReturnTransfers,
    string? PendingTransferType
);

public record ItemVerificationDetailsDto(
    Guid ItemId,
    string TitleAr, string TitleEn,
    string? ImageUrl,
    string? Condition, string? City,
    PersonInfoDto Owner,
    RentalInfoDto? ActiveRental
);

