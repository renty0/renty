
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Services
{
    public class GapAnalysisService : IGapAnalysisService
    {
        private readonly IApplicationDbContext _context;
        private readonly ILogger<GapAnalysisService> _logger;

        public GapAnalysisService(IApplicationDbContext context, ILogger<GapAnalysisService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task RunAnalysisAsync()
        {
            _logger.LogInformation("Starting Gap Analysis Pipeline...");

            // 1. Run Python Script
            // Adjust paths relative to the API running directory or usage absolute paths if confident
            // Using absolute paths based on knowledge of the workspace
            string repoRoot = @"e:\Courses\Work\renty"; // Based on context
            string scriptPath = Path.Combine(repoRoot, @"Gap_Analysis\scripts\run_pipeline.py");
            string resultPath = Path.Combine(repoRoot, @"Gap_Analysis\results\data\gap_summary.json");

            var startInfo = new ProcessStartInfo
            {
                FileName = "python",
                Arguments = $"\"{scriptPath}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                WorkingDirectory = Path.GetDirectoryName(scriptPath)
            };

            using (var process = Process.Start(startInfo))
            {
                var output = await process.StandardOutput.ReadToEndAsync();
                var error = await process.StandardError.ReadToEndAsync();
                
                process.WaitForExit();

                if (process.ExitCode != 0)
                {
                    _logger.LogError($"Python script failed. Exit Code: {process.ExitCode}. Error: {error}");
                    throw new Exception($"Gap Analysis script failed: {error}");
                }
                
                _logger.LogInformation($"Python Output: {output}");
            }

            // 2. Read Results
            if (!File.Exists(resultPath))
            {
                throw new FileNotFoundException($"Result file not found at {resultPath}");
            }

            var jsonContent = await File.ReadAllTextAsync(resultPath);
            var results = JsonSerializer.Deserialize<List<GapSummaryDto>>(jsonContent);

            if (results == null) return;

            // 3. Save to DB
            var batchId = Guid.NewGuid();
            var entities = new List<GapAnalysisResult>();

            foreach (var item in results)
            {
                entities.Add(new GapAnalysisResult
                {
                    Category = item.category,
                    Supply = item.supply,
                    Demand = item.demand,
                    GapScore = item.gap_score,
                    GapStatus = item.gap_status,
                    NormalizedGap = item.normalized_gap,
                    CreatedAt = DateTime.UtcNow,
                    BatchId = batchId
                });
            }

            // Optional: Clear old results if we only want latest on dashboard, 
            // but requirements said "Gap Analysis Pipeline... Update the DB". 
            // User also implied periodic runs. Keeping history is safer for "Analysis".
            // However, for the dashboard to show "The Results", it likely queries the latest.
            // I'll just append. The dashboard query can take the latest BatchId.
            
            await _context.GapAnalysisResults.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
            
            _logger.LogInformation($"Gap Analysis completed. Saved {entities.Count} records with BatchId {batchId}");
        }

        private class GapSummaryDto
        {
            public string category { get; set; }
            public int supply { get; set; }
            public int demand { get; set; }
            public double gap_score { get; set; }
            public string gap_status { get; set; }
            public double normalized_gap { get; set; }
        }
    }
}
