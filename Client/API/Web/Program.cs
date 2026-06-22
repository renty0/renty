using Application;
using Infrastructure;
using Infrastructure.Data;
using Web;
using Web.Hubs;
using Web.Endpoints;
using Microsoft.Extensions.FileProviders;
// Load environment variables from .env file
DotNetEnv.Env.Load(Path.Combine(Directory.GetCurrentDirectory(), "../../../.env"));

var builder = WebApplication.CreateBuilder(args);


// Add services
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddWebServices(builder.Configuration);

var app = builder.Build();

// Initialize database (runs in all environments - all seed ops are idempotent)
using (var scope = app.Services.CreateScope())
{
    var initialiser = scope.ServiceProvider.GetRequiredService<ApplicationDbContextInitialiser>();
    await initialiser.InitialiseAsync();
    await initialiser.SeedAsync();
}

// Configure middleware
app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.UseCors("AllowAll");
}
else
{
    app.UseCors("AllowAngularApp");
}

app.UseAuthentication();
app.UseAuthorization();

// Serve static files from uploads folder
var uploadsPath = Path.Combine(app.Environment.ContentRootPath, "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsPath),
    RequestPath = ""
});

// Configure Swagger
app.UseOpenApi();
app.UseSwaggerUi(config =>
{
    config.DocumentTitle = "Renty API";
    config.Path = "/swagger";
    config.DocumentPath = "/swagger/{documentName}/swagger.json";
    config.DocExpansion = "list";
});

// ── v1 API Endpoints ──────────────────────────────────────────────────────────
app.MapAuthEndpoints();              // /api/v1/auth
app.MapItemEndpoints();              // /api/v1/items
app.MapSearchEndpoints();            // /api/v1/search
app.MapFavoriteEndpoints();          // /api/v1/items/:id/favorite, /users/me/favorites
app.MapRentalEndpoints();            // /api/v1/rentals
app.MapOrderEndpoints();             // /api/v1/orders
app.MapPaymentEndpoints();           // /api/v1/payments
app.MapDeliveryEndpoints();          // /api/v1/orders/:id/delivery
app.MapReviewEndpoints();            // /api/v1/rentals/:id/review, /items/:id/reviews
app.MapVerificationEndpoints();      // /api/v1/items/:id/verify, /expert/assigned
app.MapWalletEndpoints();            // /api/v1/wallet/*
app.MapAdminSettingsEndpoints();     // /api/v1/admin/settings
app.MapAdminItemEndpoints();         // /api/v1/admin/items/*
app.MapDisputeEndpoints();           // /api/v1/support/disputes/*
app.MapSupportEndpoints();           // /api/v1/support/tickets
app.MapChatEndpoints();              // /api/v1/chats
app.MapNotificationEndpoints();      // /api/v1/notifications
app.MapRecommendationV1Endpoints();  // /api/v1/recommendations
app.MapAdminUserEndpoints();
app.MapAdminRoleEndpoints();
app.MapAdminKpiEndpoints();
app.MapGapAnalysisEndpoints();
app.MapMediaEndpoints();             // /api/v1/media
app.MapCategoryEndpoints();          // /api/v1/categories
app.MapSubcategoryEndpoints();       // /api/v1/subcategories, /api/v1/categories/:id/subcategories
app.MapBrandEndpoints();             // /api/v1/brands
app.MapPublicProfileEndpoints();      // /api/v1/public-profile



// ── SignalR Hubs ──────────────────────────────────────────────────────────────
app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<NotificationHub>("/hubs/notifications");
app.MapHub<SupportHub>("/hubs/support");

// Health check
app.MapHealthEndpoints();

app.Run();
