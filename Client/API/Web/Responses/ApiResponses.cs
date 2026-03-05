namespace Web.Responses;

// ── Generic envelope ─────────────────────────────────────────────────────────

/// <summary>
/// Unified API response envelope returned by every endpoint.
/// NSwag generates typed client methods from this wrapper.
/// </summary>
public record ApiResponse<T>(
    bool Success,
    int? SuccessCode,
    string? Message,
    T? Data,
    bool Error,
    int? ErrorCode,
    List<string>? Messages,
    int? Total = null,
    int? Page = null,
    int? Pages = null);

/// <summary>Static factory helpers — keeps endpoint code concise.</summary>
public static class Api
{
    public static IResult Ok<T>(T data, string? message = null, int code = 200)
        => Results.Json(
            new ApiResponse<T>(
                Success: true,
                SuccessCode: code,
                Message: message,
                Data: data,
                Error: false,
                ErrorCode: null,
                Messages: null),
            statusCode: code);

    public static IResult Ok<T>(PagedResult<T> paged, string? message = null, int code = 200)
        => Results.Json(
            new ApiResponse<List<T>>(
                Success: true,
                SuccessCode: code,
                Message: message,
                Data: paged.Items,
                Error: false,
                ErrorCode: null,
                Messages: null,
                Total: paged.Total,
                Page: paged.Page,
                Pages: paged.Pages),
            statusCode: code);

    public static IResult Created<T>(T data, string? message = null)
        => Results.Json(
            new ApiResponse<T>(
                Success: true,
                SuccessCode: 201,
                Message: message,
                Data: data,
                Error: false,
                ErrorCode: null,
                Messages: null),
            statusCode: 201);

    public static IResult Fail(string error, int code = 400)
        => Results.Json(
            new ApiResponse<object>(
                Success: false,
                SuccessCode: null,
                Message: null,
                Data: null,
                Error: true,
                ErrorCode: code,
                Messages: new List<string> { error }),
            statusCode: code);

    public static IResult NoContent()
        => Results.Json(
            new ApiResponse<object>(
                Success: true,
                SuccessCode: 204,
                Message: null,
                Data: null,
                Error: false,
                ErrorCode: null,
                Messages: null),
            statusCode: 204);
}

// ── Paged list result (includes sort info) ────────────────────────────────────

public record PagedResult<T>(
    List<T> Items,
    int Total,
    int Page,
    int Pages,
    string? SortBy,
    string? SortOrder);

// ── Auth ──────────────────────────────────────────────────────────────────────

public record AuthRegisterData(string Message, long? UserId);
public record AuthVerifyEmailData(string Message);
public record AuthLoginData(string? AccessToken, string? RefreshToken, DateTimeOffset? RefreshTokenExpiresAt, AuthLoginUser? User);
public record AuthLoginUser(long Id, string FirstName, string? LastName, string? Email, string? Role, string? ProfileImageUrl);
public record AuthRefreshData(string? AccessToken, string? RefreshToken);
public record AuthMeData(long Id, string FirstName, string? LastName, string? Email, string? Phone, string? City, string? Role, string? ProfileImageUrl, bool IsVerified, DateTime CreatedAt);

// ── Items ─────────────────────────────────────────────────────────────────────

public record ItemCreateData(Guid? Id);

// ── Rentals ───────────────────────────────────────────────────────────────────

public record RentalCreateData(Guid? RentalId, Guid? OrderId, decimal? RentalPrice, decimal? DepositAmount, string? Status);
public record RentalStatusData(string? Status);
public record RentalCompleteData(Guid? RentalId, string? Status, decimal? LateFee, string? DepositStatus);

// ── Orders ────────────────────────────────────────────────────────────────────

public record OrderCreateData(Guid? OrderId, decimal? TotalAmount, string? Status);

// ── Payments ──────────────────────────────────────────────────────────────────

public record PaymentCreateData(Guid? PaymentId, string? Status, string? TransactionRef);

// ── Reviews ───────────────────────────────────────────────────────────────────

public record ReviewCreateData(Guid? ReviewId, int? Rating, string? Comment);

// ── Verifications ─────────────────────────────────────────────────────────────

public record VerificationCreateData(Guid? VerificationId, string? Status);

// ── Support ───────────────────────────────────────────────────────────────────

public record SupportCreateTicketData(Guid TicketId, string Status);
public record SupportMessageData(Guid MessageId, string Message, DateTime CreatedAt);
public record SupportTicketStatusData(Guid? TicketId, string? Status);

// ── Chat ─────────────────────────────────────────────────────────────────────

public record ChatCreateData(Guid? ChatId);
public record ChatMessageData(Guid? MessageId, string? Message, DateTime? CreatedAt);

// ── Notifications ─────────────────────────────────────────────────────────────

public record NotificationMarkAllData(string Message, int Updated);

// ── Media ─────────────────────────────────────────────────────────────────────

public record MediaUploadData(
    Guid Id, string? Url, string? FileName, string? Extension,
    string? ContentType, string? FileType, long SizeBytes,
    int? Width, int? Height, DateTime CreatedAt,
    Guid? EntityId, string? EntityType);
