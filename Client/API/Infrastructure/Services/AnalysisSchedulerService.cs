
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Services
{
    public class AnalysisSchedulerService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<AnalysisSchedulerService> _logger;

        public AnalysisSchedulerService(IServiceProvider serviceProvider, ILogger<AnalysisSchedulerService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Analysis Scheduler Service is starting.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    _logger.LogInformation("Triggering Scheduled Gap Analysis...");
                    using (var scope = _serviceProvider.CreateScope())
                    {
                         var gapAnalysisService = scope.ServiceProvider.GetRequiredService<IGapAnalysisService>();
                         await gapAnalysisService.RunAnalysisAsync();
                    }
                    _logger.LogInformation("Scheduled Gap Analysis completed.");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurring executing scheduled analysis.");
                }

                // Wait 24 hours
                await Task.Delay(TimeSpan.FromHours(24), stoppingToken);
            }
        }
    }
}
