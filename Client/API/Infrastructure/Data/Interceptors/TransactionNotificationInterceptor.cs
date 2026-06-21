using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.DependencyInjection;

namespace Infrastructure.Data.Interceptors;

public class TransactionNotificationInterceptor : SaveChangesInterceptor
{
    private readonly IServiceProvider _serviceProvider;
    private List<WalletTransaction> _addedTransactions = new();

    public TransactionNotificationInterceptor(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public override InterceptionResult<int> SavingChanges(DbContextEventData eventData, InterceptionResult<int> result)
    {
        CaptureTransactions(eventData.Context);
        return base.SavingChanges(eventData, result);
    }

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(DbContextEventData eventData, InterceptionResult<int> result, CancellationToken cancellationToken = default)
    {
        CaptureTransactions(eventData.Context);
        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    public override int SavedChanges(SaveChangesCompletedEventData eventData, int result)
    {
        ProcessNotifications().GetAwaiter().GetResult();
        return base.SavedChanges(eventData, result);
    }

    public override async ValueTask<int> SavedChangesAsync(SaveChangesCompletedEventData eventData, int result, CancellationToken cancellationToken = default)
    {
        await ProcessNotifications(cancellationToken);
        return await base.SavedChangesAsync(eventData, result, cancellationToken);
    }

    private void CaptureTransactions(DbContext? context)
    {
        if (context == null) return;
        
        _addedTransactions = context.ChangeTracker.Entries<WalletTransaction>()
            .Where(e => e.State == EntityState.Added)
            .Select(e => e.Entity)
            .ToList();
    }

    private async Task ProcessNotifications(CancellationToken ct = default)
    {
        if (!_addedTransactions.Any()) return;

        var transactionsToProcess = _addedTransactions
            .Where(tx => tx.Type != TransactionType.PendingEarnings 
                      && tx.Type != TransactionType.EscrowHold 
                      && tx.Type != TransactionType.EscrowRelease)
            .ToList();
            
        _addedTransactions.Clear();

        if (!transactionsToProcess.Any()) return;

        using var scope = _serviceProvider.CreateScope();
        var notifier = scope.ServiceProvider.GetRequiredService<INotificationSender>();

        foreach (var tx in transactionsToProcess)
        {
            var amountStr = $"{Math.Abs(tx.Amount):C}";
            var action = tx.Amount >= 0 ? "credited to" : "deducted from";
            var actionAr = tx.Amount >= 0 ? "إيداع" : "خصم";
            var typeAr = tx.Type.ToString(); // Not fully localized type but understandable
            
            await notifier.SendToUserAsync(
                tx.UserId,
                "Wallet Transaction",
                $"An amount of {amountStr} was {action} your wallet for {tx.Type}.",
                "wallet",
                "/wallet",
                ct,
                "عملية محفظة",
                $"تم {actionAr} مبلغ {amountStr} في محفظتك بسبب {typeAr}."
            );
        }
    }
}
