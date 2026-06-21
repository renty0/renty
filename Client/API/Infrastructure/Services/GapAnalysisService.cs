
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
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
            _logger.LogInformation("Starting Gap Analysis Pipeline with Real Data...");

            // 1. Export Real Data from DB
            var currentDir = Directory.GetCurrentDirectory();
            var repoRoot = Path.GetFullPath(Path.Combine(currentDir, "..", "..", ".."));
            var dataExportPath = Path.Combine(repoRoot, "Gap_Analysis", "data", "live_data.json");

            var categories = await _context.ProductCategories.ToListAsync();
            var items = await _context.Items.Include(i => i.Category).ToListAsync();
            var orderItems = await _context.OrderItems.Include(oi => oi.Item).ThenInclude(i => i.Category).ToListAsync();

            var liveData = categories.Select(c => new
            {
                category = c.NameEn,
                supply = items.Count(i => i.CategoryId == c.Id),
                demand = orderItems.Where(oi => oi.Item?.CategoryId == c.Id).Sum(oi => oi.Quantity)
            }).ToList();

            await File.WriteAllTextAsync(dataExportPath, JsonSerializer.Serialize(liveData));
            _logger.LogInformation($"Live data exported to {dataExportPath}");

            // 2. Run Python Script
            var scriptPath = Path.Combine(repoRoot, "Gap_Analysis", "scripts", "run_pipeline.py");
            var resultPath = Path.Combine(repoRoot, "Gap_Analysis", "results", "data", "gap_summary.json");

            var startInfo = new ProcessStartInfo
            {
                FileName = "python3",
                Arguments = $"\"{scriptPath}\" --live",
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

            // 3. Read Results
            if (!File.Exists(resultPath))
            {
                throw new FileNotFoundException($"Result file not found at {resultPath}");
            }

            var jsonContent = await File.ReadAllTextAsync(resultPath);
            var results = JsonSerializer.Deserialize<List<GapSummaryDto>>(jsonContent);

            if (results == null) return;

            // 4. Save to DB (Latest Batch)
            var batchId = Guid.NewGuid();
            var entities = results.Select(item => new GapAnalysisResult
            {
                Category = item.category,
                Supply = item.supply,
                Demand = item.demand,
                GapScore = item.gap_score,
                GapStatus = item.gap_status,
                NormalizedGap = item.normalized_gap,
                CreatedAt = DateTime.UtcNow,
                BatchId = batchId
            }).ToList();
            
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
