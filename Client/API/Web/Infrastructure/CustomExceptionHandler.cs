using FluentValidation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Web.Responses;

namespace Web.Infrastructure;

public class CustomExceptionHandler : IExceptionHandler
{
    private readonly Dictionary<Type, Func<HttpContext, Exception, Task>> _exceptionHandlers;

    public CustomExceptionHandler()
    {
        _exceptionHandlers = new()
        {
            { typeof(ValidationException), HandleValidationException },
            { typeof(UnauthorizedAccessException), HandleUnauthorizedAccessException },
        };
    }

    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        var exceptionType = exception.GetType();

        if (_exceptionHandlers.TryGetValue(exceptionType, out var handler))
        {
            await handler.Invoke(httpContext, exception);
            return true;
        }

        return false;
    }

    private async Task HandleValidationException(HttpContext httpContext, Exception ex)
    {
        var exception = (ValidationException)ex;
        var code = StatusCodes.Status400BadRequest;
        httpContext.Response.StatusCode = code;

        var errors = exception.Errors.Select(e => e.ErrorMessage).ToList();

        await httpContext.Response.WriteAsJsonAsync(new ApiResponse<object>(
            data: null,
            error: true,
            errorCode: new List<int> { code },
            messages: errors
        ));
    }

    private async Task HandleUnauthorizedAccessException(HttpContext httpContext, Exception ex)
    {
        var code = StatusCodes.Status401Unauthorized;
        httpContext.Response.StatusCode = code;

        await httpContext.Response.WriteAsJsonAsync(new ApiResponse<object>(
            data: null,
            error: true,
            errorCode: new List<int> { code },
            messages: new List<string> { "Unauthorized access." }
        ));
    }
}
