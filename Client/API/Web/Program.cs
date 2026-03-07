using Application;
using Infrastructure;
using Infrastructure.Data;
using Web;
using Web.Hubs;
using Web.Endpoints;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

// Configure port for Render
var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Add services
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddWebServices(builder.Configuration);

var app = builder.Build();

// Initialize database
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
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
app.MapSupportEndpoints();           // /api/v1/support/tickets
app.MapChatEndpoints();              // /api/v1/chats
app.MapNotificationEndpoints();      // /api/v1/notifications
app.MapRecommendationV1Endpoints();  // /api/v1/recommendations
app.MapAdminKpiEndpoints();          // /api/v1/admin/kpis, /admin/gap
app.MapAdminFraudEndpoints();
app.MapMediaEndpoints();             // /api/v1/media
app.MapCategoryEndpoints();          // /api/v1/categories
app.MapSubcategoryEndpoints();       // /api/v1/subcategories, /api/v1/categories/:id/subcategories
app.MapBrandEndpoints();             // /api/v1/brands



// ── SignalR Hub ──────────────────────────────────────────────────────────────
app.MapHub<ChatHub>("/hubs/chat");

// Health check
app.MapGet("/", () => Results.Ok(new { Status = "Healthy", Service = "Renty API" }))
    .WithTags("Health")
    .ExcludeFromDescription();

app.Run();
