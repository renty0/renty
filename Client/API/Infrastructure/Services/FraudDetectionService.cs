using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Services;

public class FraudDetectionService : IFraudDetectionService
{
    private readonly IApplicationDbContext _context;
    private readonly ILogger<FraudDetectionService> _logger;

    public FraudDetectionService(IApplicationDbContext context, ILogger<FraudDetectionService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task LogActivityAsync(long userId, double riskScore, string decision, string reason, string indicators)
    {
        var log = new FraudLog
        {
            UserId = userId,
            RiskScore = riskScore,
            Decision = decision.ToLower(),
            Reason = reason,
            FraudIndicators = indicators,
            CreatedAt = DateTime.UtcNow
        };

        _context.FraudLogs.Add(log);
        await _context.SaveChangesAsync();
        
        _logger.LogWarning($"Fraud Activity Logged for User {userId}: {decision} - {reason} (Score: {riskScore})");
    }

    public async Task EvaluateOrderAsync(Guid orderId)
    {
        var order = await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == orderId);

        if (order == null) return;

        // Simple Rule: High Velocity Check
        var recentOrdersCount = await _context.Orders
            .CountAsync(o => o.UserId == order.UserId && o.CreatedAt >= DateTime.UtcNow.AddMinutes(-30));

        if (recentOrdersCount > 3)
        {
            await LogActivityAsync(
                order.UserId, 
                0.85, 
                "Flagged", 
                "High velocity order placement detected (3+ orders in 30 mins)", 
                $"OrdersCount: {recentOrdersCount}"
            );
        }
        
        // Simple Rule: High Value Check
        if (order.TotalAmount > 5000)
        {
             await LogActivityAsync(
                order.UserId, 
                0.6, 
                "Allowed", 
                "High value order requires secondary review", 
                $"Amount: {order.TotalAmount}"
            );
        }
    }

    public async Task EvaluateLoginAsync(long userId, string ipAddress)
    {
        // Placeholder for login fraud detection (e.g. Geo-IP mismatch)
        _logger.LogInformation($"Evaluating login for user {userId} from {ipAddress}");
    }
}
