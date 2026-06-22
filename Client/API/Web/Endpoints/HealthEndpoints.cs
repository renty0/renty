using Application.Common.Interfaces;
using CloudinaryDotNet;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using Rently.API.Application.Shared.Attributes;
using Infrastructure.Data;

namespace Web.Endpoints;

public static class HealthEndpoints
{
    public static void MapHealthEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/health", async (ApplicationDbContext dbContext, IServiceProvider serviceProvider) =>
        {
            bool databaseConnected = false;
            try
            {
                databaseConnected = await dbContext.Database.CanConnectAsync();
            }
            catch
            {
                databaseConnected = false;
            }

            var cloudinary = serviceProvider.GetService(typeof(Cloudinary)) as Cloudinary;
            bool cloudinaryConfigured = cloudinary != null;

            var status = databaseConnected ? "Healthy" : "Unhealthy";

            return Results.Ok(new
            {
                Status = status,
                Timestamp = DateTime.UtcNow,
                Checks = new
                {
                    Database = databaseConnected ? "Connected" : "Disconnected",
                    Cloudinary = cloudinaryConfigured ? "Configured" : "Not Configured"
                }
            });
        }).AllowAnonymous();
    }
}
