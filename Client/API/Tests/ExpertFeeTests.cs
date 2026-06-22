using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Application.Features.Rentals;
using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Moq;
using EntityFrameworkCoreMock;
using Xunit;

namespace Tests;

public class ExpertFeeTests
{
    private readonly Mock<IUser> _currentUserMock;
    private readonly Mock<INotificationSender> _notifierMock;
    private readonly Mock<IApplicationDbContext> _contextMock;

    public ExpertFeeTests()
    {
        _currentUserMock = new Mock<IUser>();
        _notifierMock = new Mock<INotificationSender>();
        _contextMock = new Mock<IApplicationDbContext>();
    }

    [Theory]
    [InlineData(true, true)] // Both want it
    [InlineData(true, false)]   // Only Renter wants it
    [InlineData(false, true)]   // Only Owner wants it
    [InlineData(false, false)]    // Neither wants it
    public async Task CompleteRental_ExpertFee_SplitLogic_CalculatesCorrectly(bool renterWants, bool ownerWants)
    {
        // Arrange
        var ownerId = 1L;
        var renterId = 2L;
        _currentUserMock.Setup(x => x.Id).Returns(ownerId);

        decimal initialExpertFeeDeposit = renterWants ? 100m : 0m;
        decimal depositAmount = 500m;
        decimal rentalPrice = 1000m;

        decimal renterExpertFeeShare = renterWants ? (ownerWants ? 50m : 100m) : 0m;
        decimal ownerExpertFeeShare = ownerWants ? (renterWants ? 50m : 100m) : 0m;

        // Pending balances reflect state BEFORE completion, assuming the rental was Confirmed.
        // At confirmation, RentalPrice was moved to Owner's PendingBalance.
        // If expert was NOT paid, their shares are still in pending balances.
        var owner = new ApplicationUser { Id = ownerId, PendingBalance = rentalPrice + ownerExpertFeeShare, WalletBalance = 0m };
        var renter = new ApplicationUser { Id = renterId, PendingBalance = depositAmount + renterExpertFeeShare, WalletBalance = 0m };
        var users = new List<ApplicationUser> { owner, renter };

        var item = new Item { Id = Guid.NewGuid(), OwnerId = ownerId };
        var items = new List<Item> { item };

        var rentalId = Guid.NewGuid();
        var orderId = Guid.NewGuid();
        var rental = new Rental
        {
            Id = rentalId,
            ItemId = item.Id,
            Item = item,
            UserId = renterId,
            User = renter,
            Status = RentalStatus.Active, // Fixed status
            OrderId = orderId,
            StartDate = DateTime.UtcNow.AddDays(-1),
            EndDate = DateTime.UtcNow,
            RentalPrice = rentalPrice,
            DepositAmount = depositAmount,
            PlatformCommissionPercent = 10m,
            RenterWantsExpertReview = renterWants,
            OwnerWantsExpertReview = ownerWants,
            ExpertReviewFee = initialExpertFeeDeposit, // Tracks what renter deposited
            CurrentPossession = ItemPossession.Owner,
            DepositStatus = DepositStatus.Returned,
            Images = new List<RentalImage> 
            { 
                new RentalImage { Type = RentalImageType.Return } 
            }
        };
        var rentals = new List<Rental> { rental };

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            OrderId = orderId,
            Amount = rentalPrice + depositAmount + initialExpertFeeDeposit,
            Method = PaymentMethod.Wallet,
            Status = PaymentStatus.Success
        };
        var payments = new List<Payment> { payment };

        var walletTransactions = new List<WalletTransaction>();

        // Mock DbSets
        var usersMock = new DbSetMock<ApplicationUser>(users, (x, _) => x.Id);
        var itemsMock = new DbSetMock<Item>(items, (x, _) => x.Id);
        var rentalsMock = new DbSetMock<Rental>(rentals, (x, _) => x.Id);
        var paymentsMock = new DbSetMock<Payment>(payments, (x, _) => x.Id);
        var walletTransactionsMock = new DbSetMock<WalletTransaction>(walletTransactions, (x, _) => x.Id);
        walletTransactionsMock.Setup(d => d.Add(It.IsAny<WalletTransaction>())).Callback<WalletTransaction>(walletTransactions.Add);

        var favoritesMock = new DbSetMock<Favorite>(new List<Favorite>(), (x, _) => x.Id);
        var itemRemindersMock = new DbSetMock<ItemReminder>(new List<ItemReminder>(), (x, _) => x.Id);

        var rentalTransfersMock = new DbSetMock<RentalTransfer>(new List<RentalTransfer>(), (x, _) => x.Id);
        var systemSettingsMock = new DbSetMock<SystemSetting>(new List<SystemSetting> { new SystemSetting { Key = "CancellationFee", Value = "500" } }, (x, _) => x.Key);

        _contextMock.Setup(c => c.Users).Returns(usersMock.Object);
        _contextMock.Setup(c => c.Items).Returns(itemsMock.Object);
        _contextMock.Setup(c => c.Rentals).Returns(rentalsMock.Object);
        _contextMock.Setup(c => c.Payments).Returns(paymentsMock.Object);
        _contextMock.Setup(c => c.WalletTransactions).Returns(walletTransactionsMock.Object);
        _contextMock.Setup(c => c.Favorites).Returns(favoritesMock.Object);
        _contextMock.Setup(c => c.ItemReminders).Returns(itemRemindersMock.Object);
        _contextMock.Setup(c => c.RentalTransfers).Returns(rentalTransfersMock.Object);
        _contextMock.Setup(c => c.SystemSettings).Returns(systemSettingsMock.Object);

        var handler = new CompleteRentalCommandHandler(_contextMock.Object, _currentUserMock.Object, _notifierMock.Object);

        var command = new CompleteRentalCommand(rentalId, false);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.True(result.Success, "Expected handler to succeed");

        var updatedRental = _contextMock.Object.Rentals.First(r => r.Id == rentalId);
        var updatedRenter = _contextMock.Object.Users.First(u => u.Id == renterId);
        var updatedOwner = _contextMock.Object.Users.First(u => u.Id == ownerId);

        Assert.Equal(RentalStatus.Completed, updatedRental.Status);

        // Validate Renter Balances
        // PendingBalance should be exactly 0 after deducting Deposit and their Share
        Assert.Equal(0m, updatedRenter.PendingBalance);
        
        // Since IsExpertPaid is false, the expert fee is REFUNDED entirely.
        Assert.Equal(depositAmount + renterExpertFeeShare, updatedRenter.WalletBalance);

        // Validate Owner Balances
        // Commission is 10% of 1000 = 100
        decimal commission = 100m;
        
        Assert.Equal(0m, updatedOwner.PendingBalance); // The initial hold was reverted
        
        // Owner gets their RentalPrice minus commission, PLUS their expert fee refunded
        decimal expectedOwnerWallet = (rentalPrice - commission) + ownerExpertFeeShare;
        Assert.Equal(expectedOwnerWallet, updatedOwner.WalletBalance);
    }
}
