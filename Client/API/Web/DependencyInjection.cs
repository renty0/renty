using System.Security.Claims;
using Application.Features.Chats;
using NSwag;
using NSwag.Generation.Processors.Security;
using Application.Web.MediaFiles.Commands.UploadMedia;
using Web.Hubs;
using Web.Infrastructure;
using Web.Services;

namespace Web;

public static class DependencyInjection
{
    public static IServiceCollection AddWebServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<FileUploadSettings>(configuration.GetSection("FileUploadSettings"));

        services.AddHttpContextAccessor();
        services.AddExceptionHandler<CustomExceptionHandler>();
        services.AddProblemDetails();

        // ── Real-Time (SignalR) ────────────────────────────────────────────────
        services.AddSignalR();
        services.AddScoped<IChatNotifier, ChatHubNotifier>();

        // ── Authorization Policies ────────────────────────────────────────────
        services.AddAuthorization(options =>
        {
            var adminEmail = Environment.GetEnvironmentVariable("SEED_ADMIN_EMAIL") ?? "admin@rently.com";

            options.AddPolicy(Policies.AdminAccess, p =>
                p.RequireAssertion(context =>
                    context.User.IsInRole(Roles.Admin) || 
                    context.User.IsInRole(Roles.SuperAdmin) ||
                    context.User.FindFirstValue(ClaimTypes.Email) == adminEmail));

            options.AddPolicy(Policies.SuperAdminOnly, p =>
                p.RequireAssertion(context =>
                    context.User.IsInRole(Roles.SuperAdmin) ||
                    context.User.FindFirstValue(ClaimTypes.Email) == adminEmail));

            options.AddPolicy(Policies.SupportAccess, p =>
                p.RequireAssertion(context =>
                    context.User.IsInRole(Roles.Support) ||
                    context.User.IsInRole(Roles.Admin) || 
                    context.User.IsInRole(Roles.SuperAdmin) ||
                    context.User.FindFirstValue(ClaimTypes.Email) == adminEmail));

            options.AddPolicy(Policies.ExpertAccess, p =>
                p.RequireRole(Roles.Expert));

            options.AddPolicy(Policies.ExpertOrAdmin, p =>
                p.RequireAssertion(context =>
                    context.User.IsInRole(Roles.Expert) ||
                    context.User.IsInRole(Roles.Admin) || 
                    context.User.IsInRole(Roles.SuperAdmin) ||
                    context.User.FindFirstValue(ClaimTypes.Email) == adminEmail));

            // Any authenticated role (all users, EXCLUDES experts for transactional ops)
            options.AddPolicy(Policies.CanTransact, p =>
                p.RequireRole(Roles.Renter, Roles.Owner, Roles.Admin, Roles.SuperAdmin));

            // Non-expert authenticated user (renter/owner/admin/support/super_admin)
            options.AddPolicy(Policies.NonExpert, p =>
                p.RequireRole(Roles.Renter, Roles.Owner, Roles.Admin, Roles.Support, Roles.SuperAdmin));
        });

        // Configure CORS
        services.AddCors(options =>
        {
            options.AddPolicy("AllowAll", policy =>
            {
                policy.SetIsOriginAllowed(_ => true)
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials();
            });

            options.AddPolicy("AllowAngularApp", policy =>
            {
                var origins = Environment.GetEnvironmentVariable("CORS_ALLOWED_ORIGINS")?.Split(',')
                    ?? new[] { "http://localhost:4200" };

                policy.WithOrigins(origins)
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials();
            });
        });

        // Configure OpenAPI/Swagger
        services.AddEndpointsApiExplorer();
        services.AddOpenApiDocument(config =>
        {
            config.PostProcess = document =>
            {
                document.Info.Version = "v1";
                document.Info.Title = "Renty API";
                document.Info.Description = "Renty - Rental Marketplace API";
            };

            config.AddSecurity("JWT", new OpenApiSecurityScheme
            {
                Type = OpenApiSecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                Description = "Enter your JWT token"
            });

            config.OperationProcessors.Add(new AspNetCoreOperationSecurityScopeProcessor("JWT"));
        });

        return services;
    }
}
