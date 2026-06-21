namespace Web.Responses;

// ── Generic envelope ─────────────────────────────────────────────────────────

/// <summary>
/// Unified API response envelope returned by every endpoint.
/// NSwag generates typed client methods from this wrapper.
/// </summary>
public class ApiResponse<T>
{
    public T? Data { get; set; }
    public bool Error { get; set; }
    public List<int>? ErrorCode { get; set; }
    public List<string>? Messages { get; set; }
    public int? Total { get; set; }
    public int? Page { get; set; }
    public int? Pages { get; set; }
    public int? SuccessCode { get; set; }

    public ApiResponse() { }

    public ApiResponse(
        T? data,
        bool error,
        List<int>? errorCode,
        List<string>? messages,
        int? total = null,
        int? page = null,
        int? pages = null,
        int? successCode = null)
    {
        Data = data;
        Error = error;
        ErrorCode = errorCode;
        Messages = messages;
        Total = total;
        Page = page;
        Pages = pages;
        SuccessCode = successCode;
    }
}

// NoData record removed

/// <summary>Static factory helpers — keeps endpoint code concise.</summary>
public static class Api
{
    public static IResult Ok<T>(T data, string? message = null, int code = 200)
        => Results.Json(
            new ApiResponse<T>(
                data: data,
                error: false,
                errorCode: null,
                messages: message != null ? new List<string> { message } : null,
                successCode: code),
            statusCode: code);

    public static IResult Ok<T>(PagedResult<T> paged, string? message = null, int code = 200)
        => Results.Json(
            new ApiResponse<List<T>>(
                data: paged.Items,
                error: false,
                errorCode: null,
                messages: message != null ? new List<string> { message } : null,
                total: paged.Total,
                page: paged.Page,
                pages: paged.Pages,
                successCode: code),
            statusCode: code);

    public static IResult Created<T>(T data, string? message = null)
        => Results.Json(
            new ApiResponse<T>(
                data: data,
                error: false,
                errorCode: null,
                messages: message != null ? new List<string> { message } : null,
                successCode: 201),
            statusCode: 201);

    public static IResult Fail(string error, int code = 400)
        => Results.Json(
            new ApiResponse<object>(
                data: null,
                error: true,
                errorCode: new List<int> { code },
                messages: new List<string> { error }),
            statusCode: code);

    public static IResult Fail(IEnumerable<string> errors, int code = 400)
        => Results.Json(
            new ApiResponse<object>(
                data: null,
                error: true,
                errorCode: new List<int> { code },
                messages: errors.ToList()),
            statusCode: code);

    public static IResult NoContent()
        => Results.Json(
            new ApiResponse<object>(
                data: null,
                error: false,
                errorCode: null,
                messages: null,
                successCode: 204),
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
public record AuthLoginUser(long Id, string FirstName, string? LastName, string? Email, string? Role, string? ProfileImageUrl, IList<string>? Permissions = null, string? IdVerificationStatus = null, bool IdVerified = false, bool IsVerified = false);
public record AuthRefreshData(string? AccessToken, string? RefreshToken);
public record AuthMeData(long Id, string FirstName, string? LastName, string? Email, string? Phone, string? City, string? Role, string? ProfileImageUrl, bool IsVerified, DateTime CreatedAt, IList<string>? Permissions = null, string? IdVerificationStatus = null, bool IdVerified = false);

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

public record SupportCreateTicketData(Guid TicketId, string Status, object? AutoReplyMessage = null);
public record SupportMessageData(Guid MessageId, string Message, string? MediaUrl, Domain.Enums.MessageType MessageType, DateTime CreatedAt);
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
