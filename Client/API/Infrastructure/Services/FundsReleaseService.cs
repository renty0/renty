using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Services;

public class FundsReleaseService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<FundsReleaseService> _logger;

    public FundsReleaseService(IServiceProvider serviceProvider, ILogger<FundsReleaseService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("FundsReleaseService is starting.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ReleasePendingFundsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while executing FundsReleaseService.");
            }

            // Run every 10 minutes
            await Task.Delay(TimeSpan.FromMinutes(10), stoppingToken);
        }

        _logger.LogInformation("FundsReleaseService is stopping.");
    }

    private async Task ReleasePendingFundsAsync(CancellationToken stoppingToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IApplicationDbContext>();
        var notifier = scope.ServiceProvider.GetRequiredService<INotificationSender>();

        var now = DateTimeOffset.UtcNow;

        var pendingTransactions = await context.WalletTransactions
            .Include(t => t.User)
            .Where(t => t.IsPending && t.ReleaseDate != null && t.ReleaseDate <= now)
            .ToListAsync(stoppingToken);

        if (!pendingTransactions.Any())
            return;

        _logger.LogInformation($"Found {pendingTransactions.Count} pending transactions to release.");

        foreach (var transaction in pendingTransactions)
        {
            if (transaction.User == null) continue;

            // Release the funds
            transaction.User.PendingBalance -= transaction.Amount;
            transaction.User.WalletBalance += transaction.Amount;
            
            transaction.IsPending = false;
            
            // Optionally, add a ledger entry representing the release
            context.WalletTransactions.Add(new WalletTransaction
            {
                UserId = transaction.User.Id,
                Amount = transaction.Amount,
                Type = TransactionType.EscrowRelease,
                Description = $"Cleared pending earnings for transaction {transaction.Id}",
                RelatedRentalId = transaction.RelatedRentalId,
                IsPending = false,
                CreatedAt = DateTimeOffset.UtcNow
            });

            await notifier.SendToUserAsync(
                transaction.User.Id,
                "Funds Released",
                $"Your pending earnings of {transaction.Amount:C} have been cleared and are now available in your wallet.",
                "wallet",
                "/wallet",
                stoppingToken,
                "تم تحرير الأموال",
                $"تم تحرير أرباحك المعلقة بقيمة {transaction.Amount:C} وهي الآن متاحة في محفظتك."
            );
        }

        await context.SaveChangesAsync(stoppingToken);
    }
}
