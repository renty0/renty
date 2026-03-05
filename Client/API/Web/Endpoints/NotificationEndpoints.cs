using Application.Features.Notifications;
using MediatR;
using Microsoft.AspNetCore.Http;
using Web.Responses;

namespace Web.Endpoints;

public static class NotificationEndpoints
{
    public static void MapNotificationEndpoints(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/api/v1/notifications").WithTags("Notifications").RequireAuthorization();

        // GET /notifications
        g.MapGet("/", async (ISender sender) =>
        {
            var r = await sender.Send(new GetNotificationsQuery());
            return Api.Ok(r);
        })
        .WithName("GetNotifications")
        .Produces<ApiResponse<GetNotificationsResponse>>(StatusCodes.Status200OK);

        // PUT /notifications/read-all
        g.MapPut("/read-all", async (ISender sender) =>
        {
            var r = await sender.Send(new MarkAllNotificationsReadCommand());
            return Api.Ok(new NotificationMarkAllData("All marked as read", r.Updated));
        })
        .WithName("MarkAllNotificationsRead")
        .Produces<ApiResponse<NotificationMarkAllData>>(StatusCodes.Status200OK);

        // PUT /notifications/:id/read
        g.MapPut("/{id:guid}/read", async (Guid id, ISender sender) =>
        {
            var r = await sender.Send(new MarkNotificationReadCommand(id));
            if (!r.Success) return Api.Fail(r.Error ?? "Not found", 404);
            return Api.Ok(new { message = "Marked as read" });
        })
        .WithName("MarkNotificationRead")
        .Produces<ApiResponse<object>>(StatusCodes.Status200OK)
        .Produces<ApiResponse<object>>(StatusCodes.Status404NotFound);
    }
}
