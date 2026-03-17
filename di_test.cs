using System;
using System.Security.Cryptography;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Infrastructure;
using Infrastructure.Identity;

class Program
{
    static void Main()
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(System.IO.Directory.GetCurrentDirectory() + "\\Client\\API\\Web")
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .AddJsonFile("appsettings.Development.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        var services = new ServiceCollection();
        services.AddSingleton<IConfiguration>(configuration);
        services.AddInfrastructureServices(configuration);

        var serviceProvider = services.BuildServiceProvider();

        var jwtSettings = serviceProvider.GetRequiredService<IOptions<JwtSettings>>().Value;

        Console.WriteLine($"\n--- TEST RESULTS ---");
        Console.WriteLine($"Loaded Key: {jwtSettings.Key}");
        Console.WriteLine($"Length: {jwtSettings.Key.Length}");
        Console.WriteLine($"Issuer: {jwtSettings.Issuer}");
        Console.WriteLine($"Audience: {jwtSettings.Audience}");
        Console.WriteLine($"--------------------");
    }
}
