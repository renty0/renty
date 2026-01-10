using Application;
using Infrastructure;
using Infrastructure.Data;
using Web;
using Web.Endpoints;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddWebServices();

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

// Health check
app.MapGet("/", () => Results.Ok(new { Status = "Healthy", Service = "Renty API" }))
    .WithTags("Health")
    .ExcludeFromDescription();

app.Run();
