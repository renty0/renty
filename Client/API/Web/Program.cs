using Application;
using Infrastructure;
using Infrastructure.Data;
using Web;
using Web.Endpoints;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

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

// Map endpoints
app.MapAccountEndpoints();
app.MapCategoryEndpoints();
app.MapSubcategoryEndpoints();
app.MapProductEndpoints();
app.MapCustomerEndpoints();
app.MapTerritoryEndpoints();
app.MapSaleEndpoints();
app.MapReturnEndpoints();
app.MapCalendarEndpoints();
app.MapRentableItemEndpoints();
app.MapRentRequestEndpoints();
app.MapMediaFilesEndpoints();
app.MapDashboardEndpoints();
app.MapRecommendationEndpoints();
app.MapAnalyticsEndpoints();

// Health check
app.MapGet("/", () => Results.Ok(new { Status = "Healthy", Service = "Renty API" }))
    .WithTags("Health")
    .ExcludeFromDescription();

app.Run();
